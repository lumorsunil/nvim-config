local M = {}

local util = require("daily-todos.util")
local section = require("daily-todos.section")

function M.daily_next()
    local next_entry = util.find_next_existing_entry(true)
    if next_entry == nil then
        print("Next daily todo entry not found.")
        return
    end
    util.open_daily_todo(next_entry)
end

function M.daily_move_to_next()
    local current_line = vim.fn.line('.')
    local item = vim.fn.getline('.')
    local tabnr = vim.fn.tabpagenr()
    local current_section = section.get_section(current_line)
    if current_section == nil then error("Not in a section") end
    if current_section == section.Section.MovedToNext then error("Cannot move from this section") end
    local next_entry = util.find_next_existing_entry(false)
    if next_entry == nil then error("Next entry not found") end
    section.section_remove_item(current_section, current_line)
    section.section_add_item(section.Section.MovedToNext, item)
    util.open_daily_todo(next_entry, true)
    section.section_add_item(section.Section.MovedFromPrevious, item)
    vim.cmd.tabnext("" .. tabnr)
end

function M.daily_toggle_task()
    local item = vim.fn.getline('.')
    local search = vim.fn.getreg('/')
    if string.find(item, "^%s*%-%s*%[ %]") then
        local r = ".s/^\\(\\s*-\\s*\\)\\[ \\]/\\1[x]/e"
        vim.cmd(r)
    else
        local r = ".s/^\\(\\s*-\\s*\\)\\[x\\]/\\1[ ]/e"
        vim.cmd(r)
    end
    vim.fn.setreg('/', search)
end

function M.daily_prev()
    local prev_entry = util.find_previous_existing_entry(true)
    if prev_entry == nil then
        print("Previous daily todo entry not found.")
        return
    end
    util.open_daily_todo(prev_entry)
end

function M.open_today()
    if vim.fn.expand('%') == '' then
        util.open_daily_todo(util.get_entry_path(util.get_autoselect_date()))
        -- This does not trigger automatically when opening the file, so we need to manually call BufReadPost event
        vim.cmd [[do BufReadPost]]
    end
end

function M.refresh()
    util.open_daily_todo(vim.fn.expand('%'))
end

---@type number | nil
M.publish_terminal = nil

---@param output string[]
---@param show? boolean
local function _publish_cmd_show_output(output, show)
    ---@param d string[]
    return function(_, d, _)
        for _, x in ipairs(d) do
            table.insert(output, x)
        end
        if show then
            vim.api.nvim_chan_send(M.publish_terminal, vim.fn.join(d, "\n\r"))
        end
    end
end

---@param command string
---@param output string[]
---@param opts { show_output?: boolean, on_exit?: fun(output: string[], defer?: fun()), defer?: fun() }
local function _publish_cmd_handle_exit(command, output, opts)
    ---@param code integer
    return function(_, code, _)
        if code ~= 0 then
            if not opts.show_output then
                vim.api.nvim_chan_send(M.publish_terminal, vim.fn.join(output, "\r\n"))
            end
            vim.api.nvim_chan_send(M.publish_terminal,
                "\n\rError running command \"" .. command .. "\", exited with code " .. tostring(code))
            if opts.defer then opts.defer() end
            return
        end
        if opts.on_exit then
            opts.on_exit(output, opts.defer)
        else
            if opts.defer then opts.defer() end
        end
    end
end

---@param command string
---@param opts? { show_output?: boolean, on_exit?: fun(output: string[], defer?: fun()), defer?: fun() }
local function publish_cmd(command, opts)
    opts = opts or {}
    ---@type string[]
    local output = {}
    local handle_output = _publish_cmd_show_output(output, opts.show_output)
    local handle_exit = _publish_cmd_handle_exit(command, output, opts)
    vim.fn.jobstart(command, {
        pty = true,
        on_stdout = handle_output,
        on_stderr = handle_output,
        on_exit = handle_exit,
    })
end

function M.publish()
    -- Close terminal if success
    local buf = vim.api.nvim_create_buf(false, true)
    vim.fn.setbufvar(buf, "&termguicolors", true)
    vim.api.nvim_open_win(buf, true,
        { relative = "editor", width = 100, height = 40, row = 5, col = 5, border = "single", title = "Publish Changes" })
    M.publish_terminal = vim.api.nvim_open_term(buf, {})
    vim.cmd [[noremap <buffer> <Esc> <cmd>bdelete<cr>]]
    vim.cmd [[noremap <buffer> q <cmd>bdelete<cr>]]
    publish_cmd(
        "git status -s",
        {
            on_exit = M._publish_continue_stage_commit_push,
            show_output = false,
            defer = function()
                vim.fn.chanclose(M.publish_terminal)
                M.publish_terminal = nil
            end
        }
    )
end

---@param output string[]
---@param defer? fun()
function M._publish_continue_stage_commit_push(output, defer)
    local nonempty_output = {}
    for _, l in ipairs(output) do
        if #l > 0 then
            table.insert(nonempty_output, l)
        end
    end
    if #nonempty_output == 0 then
        vim.api.nvim_chan_send(M.publish_terminal, "No changes detected.")
        if defer then defer() end
        return
    end
    vim.api.nvim_chan_send(M.publish_terminal, "Publishing changes:\n\n\r")
    vim.api.nvim_chan_send(M.publish_terminal, vim.fn.join(nonempty_output, "\n\r"))
    vim.api.nvim_chan_send(M.publish_terminal, "\n\r")
    publish_cmd(
        "git add . && git commit -m \"Published changes\" && git push",
        {
            show_output = false,
            on_exit = M._publish_continue_end,
            defer = defer,
        }
    )
end

---@param _ string[]
---@param defer? fun()
function M._publish_continue_end(_, defer)
    vim.api.nvim_chan_send(M.publish_terminal, "\n\rSaved changes.\n\r")
    if defer then defer() end
end

function M.stand_view()
    local today = util.get_todays_date()
    util.open_daily_todo(util.get_entry_path(today))
    vim.cmd [[leftabove vsplit]]
    M.daily_prev()
end

---@param date string
local function is_last_workday_in_month(date)
    local year_month = string.sub(date, 1, #"2000-01")
    local last_workday_in_month = vim.fn.system([[date -d "]] ..
        year_month ..
        [[-01 +1 month -1 day" "+%u %d" | awk '{ n = $1; if (n > 5) printf "]] ..
        year_month .. "-" .. [[%02d", $2-(n-5); else printf "]] .. year_month .. [[-%s", $2 }' ]])
    return date == last_workday_in_month
end

function M.setup()
    local root_path = util.get_root_path()

    if vim.fn.getcwd() ~= root_path then return end

    vim.api.nvim_create_user_command("DailyNext", M.daily_next, {
        desc = "Edit next daily todo entry"
    })

    vim.api.nvim_create_user_command("DailyPrev", M.daily_prev, {
        desc = "Edit previous daily todo entry"
    })

    vim.api.nvim_create_user_command("DailyMoveToNext", M.daily_move_to_next, {
        desc = "Moves task under cursor to next daily todo entry"
    })

    vim.api.nvim_create_user_command("DailyToggleTaskDone", M.daily_toggle_task, {
        desc = "Toggles selected task"
    })

    vim.api.nvim_create_user_command("DailyPublish", M.publish, {
        desc = "Publishes changes to remote"
    })

    vim.api.nvim_create_user_command("DailyStandupView", M.stand_view, {
        desc = "Shows today's daily notes and previous daily notes"
    })

    vim.api.nvim_create_augroup("DailyTodo", { clear = true })
    vim.api.nvim_create_autocmd({ "VimEnter" }, {
        group = "DailyTodo",
        pattern = { "*" },
        callback = M.open_today,
    })
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        group = "DailyTodo",
        pattern = { "daily-todo-*.md" },
        callback = M.refresh,
    })

    require("daily-todos.util").register_auto_task_handler(function(date)
        if is_last_workday_in_month(date) then
            return { "END OF MONTH: Report work time" }
        end
        return {}
    end)

    require("hook.keybind").hooks.daily_todo()
end

return M
