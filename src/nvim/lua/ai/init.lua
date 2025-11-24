local M = {}

local function normalize_lines(value)
    if type(value) == "table" then
        return value
    end

    return { value }
end

local function get_relative_bufname()
    local buf_name = vim.api.nvim_buf_get_name(0)
    if buf_name == "" then
        return "[No Name]"
    end

    local relative = vim.fn.fnamemodify(buf_name, ":.")
    if relative == "" then
        return buf_name
    end

    return relative
end

local function get_selected_text(opts)
    if opts.range == 0 then
        return nil
    end

    local context = {
        file = get_relative_bufname(),
        range = nil,
    }

    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local start_line = start_pos[2]
    local end_line = end_pos[2]

    if start_line == 0 or end_line == 0 then
        local lines = normalize_lines(vim.fn.getline(opts.line1, opts.line2))
        context.text = table.concat(lines, "\n")
        return context
    end

    local min_line = math.min(start_line, end_line)
    local max_line = math.max(start_line, end_line)
    local use_marks = min_line == opts.line1 and max_line == opts.line2

    local lines = normalize_lines(vim.fn.getline(opts.line1, opts.line2))
    if not use_marks then
        context.text = table.concat(lines, "\n")
        return context
    end

    local start_col = start_pos[3]
    local end_col = end_pos[3]
    local visual_mode = vim.fn.visualmode()

    if visual_mode == "\22" then
        local left = math.min(start_col, end_col)
        local right = math.max(start_col, end_col)
        for idx, line in ipairs(lines) do
            local line_len = #line
            if line_len == 0 or left > line_len then
                lines[idx] = ""
            else
                lines[idx] = string.sub(line, left, math.min(right, line_len))
            end
        end
    elseif min_line == max_line then
        lines[1] = string.sub(lines[1], math.max(1, start_col), end_col)
    else
        local first = string.sub(lines[1], math.max(1, start_col))
        local last = string.sub(lines[#lines], 1, end_col)
        lines[1] = first
        lines[#lines] = last
    end

    local start_range_line = min_line
    local end_range_line = max_line
    local start_range_col = start_col
    local end_range_col = end_col

    if visual_mode ~= "\22" then
        if start_line > end_line or (start_line == end_line and start_col > end_col) then
            start_range_line, start_range_col = end_line, end_col
            end_range_line, end_range_col = start_line, start_col
        else
            start_range_line, start_range_col = start_line, start_col
            end_range_line, end_range_col = end_line, end_col
        end
    else
        start_range_col = math.min(start_col, end_col)
        end_range_col = math.max(start_col, end_col)
    end

    context.range = {
        start_line = start_range_line,
        start_col = start_range_col,
        end_line = end_range_line,
        end_col = end_range_col,
    }
    context.text = table.concat(lines, "\n")
    return context
end

local function open_codex_output_when_ready(task, attempt)
    attempt = attempt or 0

    if not task or type(task.get_bufnr) ~= "function" or task:is_disposed() then
        return
    end

    if task:get_bufnr() then
        local original_win = vim.api.nvim_get_current_win()
        local original_splitright = vim.o.splitright
        local function restore_layout()
            if vim.o.splitright ~= original_splitright then
                vim.o.splitright = original_splitright
            end
            if vim.api.nvim_win_is_valid(original_win) then
                vim.api.nvim_set_current_win(original_win)
            end
        end

        local ok, err = pcall(function()
            if not original_splitright then
                vim.o.splitright = true
            end
            task:open_output("vertical")
        end)

        restore_layout()

        if not ok then
            vim.notify(string.format("Failed to open Codex output: %s", err), vim.log.levels.WARN)
        end
        return
    end

    if attempt >= 10 then
        return
    end

    vim.defer_fn(function()
        open_codex_output_when_ready(task, attempt + 1)
    end, 50)
end

local function run_codex_command(cmd)
    local ok, overseer = pcall(require, "overseer")
    if not ok then
        vim.notify("codex.nvim requires overseer.nvim", vim.log.levels.ERROR)
        return false
    end

    overseer.run_template({
        name = "shell",
        params = { cmd = cmd },
    }, function(task)
        if task then
            open_codex_output_when_ready(task)
        end
    end)

    return true
end

local function codex_exec(opts)
    local prompt = opts.args
    local selection = get_selected_text(opts)

    if selection and selection.text and selection.text ~= "" then
        local location = selection.file
        if selection.range then
            location = string.format(
                "%s L%dC%d-L%dC%d",
                location,
                selection.range.start_line,
                selection.range.start_col,
                selection.range.end_line,
                selection.range.end_col
            )
        end
        prompt = string.format("%s\n\nContext (%s):\n%s", prompt, location, selection.text)
    end

    local shell_arg = vim.fn.shellescape(prompt)
    local ok = run_codex_command(string.format("codex exec %s", shell_arg))
    if not ok then
        return
    end
end

function M.prompt_codex_exec(opts)
    opts = opts or {}

    -- Use explicit numeric ranges so the command-line parser doesn't try to
    -- expand :'<,'> wildcards when a visual selection is present.
    local function run_with_range(input, range_mode)
        if range_mode == "visual" then
            local start_line = vim.fn.line("'<")
            local end_line = vim.fn.line("'>")
            if start_line > 0 and end_line > 0 then
                local min_line = math.min(start_line, end_line)
                local max_line = math.max(start_line, end_line)
                vim.cmd(string.format("%d,%dCodexExec %s", min_line, max_line, input))
                return
            end
        end

        vim.cmd("CodexExec " .. input)
    end

    local function handler(input)
        if not input or input == "" then
            return
        end

        if opts.range == "visual" then
            run_with_range(input, "visual")
        else
            run_with_range(input)
        end
    end

    if vim.ui and vim.ui.input then
        vim.ui.input({ prompt = opts.prompt or "Codex prompt: " }, handler)
    else
        handler(vim.fn.input(opts.prompt or "Codex prompt: "))
    end
end

function M.setup()
    vim.api.nvim_create_user_command("CodexExec", codex_exec, {
        nargs = "+",
        range = true,
    })

    require("hook.keybind").hooks.ai()
end

return M
