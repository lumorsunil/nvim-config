-- @keybind

local core = require("hook.keybind_core")
local nmap = core.nmap
local vmap = core.vmap
local mkbind = core.mkbind

local keybind_table = {} -- HookTable.new()

function keybind_table.setup()
    vim.cmd [[let mapleader="§"]]
end

function keybind_table.which_key()
    local wk = require("which-key")

    -- Mapping group labels
    wk.add({
        { ",",          desc = "Repeat latest f, t, F or T in opposite direction" },
        { ";",          desc = "Repeat latest f, t, F or T" },
        { "<leader>d",  group = "debug" },
        { "<leader>e",  group = "diagnostic" },
        { "<leader>f",  group = "find" },
        { "<leader>j",  group = "jira" },
        { "<leader>p",  group = "profiling" },
        { "<leader>pl", group = "load" },
        { "<leader>r",  group = "rest" },
        { "<leader>s",  group = "streaming" },
        { "<leader>t",  group = "tree_or_tsnav" },
        { "<leader>v",  group = "visual" },
    })

    nmap({
        ["<leader><leader>"] = mkbind("<cmd>WhichKey<cr>", "Show keymap"),
    })
end

-- @general.keybind
function keybind_table.general()
    vim.cmd [[echo g:mapleader]]
    nmap({
        ["<leader>ef"] = mkbind(vim.diagnostic.open_float, "diagnostic.open_float"),
        ["<F1>"] = mkbind(function()
            if vim.bo.buftype == "help" then
                vim.cmd [[q]]
            else
                vim.cmd [[help]]
            end
        end, "diagnostic.goto_next"),
        ["<F8>"] = mkbind(vim.diagnostic.goto_next, "diagnostic.goto_next"),
        ["<F20>"] = mkbind(vim.diagnostic.goto_prev, "diagnostic.goto_prev"),
        ["gx"] = "<Cmd>URLOpenUnderCursor<CR>",
        ["<leader>vc"] = mkbind(
            function()
                vim.cmd [[let @/ = ""]]
                vim.cmd [[silent! NvimTreeClose]]
                vim.cmd [[silent! OutlineClose]]
            end,
            "clear search highlights, temp windows, etc"
        ),
        ["<C-Up>"] = mkbind("<cmd>m -2<cr>==", "Move line up"),
        ["<C-Down>"] = mkbind("<cmd>m +1<cr>==", "Move line down"),
        ["<Esc>"] = mkbind(
            function()
                vim.cmd [[let @/ = ""]]
            end,
            "clear search highlights"
        ),
        ["<leader>sl"] = mkbind("<Cmd>silent! source session.vim | silent! source session.lua<CR>",
            "Source session.vim or session.lua.")
    })

    vmap({
        ["<C-Up>"] = mkbind(":m '<-2<cr>gv=gv", "Move line(s) up"),
        ["<C-Down>"] = mkbind(":m '>+1<cr>gv=gv", "Move line(s) down"),
        ["<<"] = mkbind(function()
            vim.cmd [[normal! <<]]
            vim.cmd [[normal! gv]]
        end, "Indent less"),
        [">>"] = mkbind(function()
            vim.cmd [[normal! >>]]
            vim.cmd [[normal! gv]]
        end, "Indent more"),
    })
end

-- @jira.keybind
function keybind_table.jira()
    nmap({
        ["<leader>jp"] = mkbind("<cmd>JiraInProgress<cr>", "Show JIRA issue currently in progress"),
        ["<leader>js"] = mkbind("<cmd>JiraSync<cr>", "Sync JIRA issues"),
    })
end

-- @telescope.keybind
function keybind_table.telescope()
    local builtin = require("telescope.builtin")
    local remote_plugins = require("remote_plugins.picker").picker
    local themes = require("telescope.themes")
    local with = function(f, opts)
        return function()
            return f(opts)
        end
    end
    local alternative = function(fn1, fn2)
        return function()
            local ok, _ = pcall(fn1)
            if ok then return end
            fn2()
        end
    end

    nmap({
        ["<leader>el"] = mkbind(with(builtin.diagnostics, themes.get_ivy()), "Diagnostics"),
        ["<C-p>"] = mkbind(builtin.find_files, "Find files"),
        ["<leader>ff"] = mkbind(builtin.find_files, "Find files"),
        ["<leader>fg"] = mkbind(builtin.live_grep, "Live grep"),
        ["<leader>fb"] = mkbind(builtin.buffers, "Buffers"),
        ["<leader>fh"] = mkbind(builtin.help_tags, "Help tags"),
        ["<leader>fm"] = mkbind(builtin.keymaps, "Keymaps"),
        ["<leader>fx"] = mkbind(with(builtin.builtin, { include_extensions = true }), "Telescope pickers"),
        ["gd"] = mkbind(
            alternative(
                with(builtin.lsp_definitions, themes.get_ivy()),
                vim.lsp.buf.definition
            ),
            "Definitions"),
        ["gr"] = mkbind(
            alternative(
                with(builtin.lsp_references, themes.get_ivy()),
                vim.lsp.buf.references
            ),
            "References"),
        ["gi"] = mkbind(
            alternative(
                with(builtin.lsp_implementations, themes.get_ivy()),
                vim.lsp.buf.implementation
            ),
            "Implementations"),
        ["<space>D"] = mkbind(
            alternative(
                with(builtin.lsp_type_definitions, themes.get_ivy()),
                vim.lsp.buf.type_definition
            ),
            "Type definitions"),
        ["<leader>fr"] = mkbind("<Cmd>Telescope smart_open<CR>", "Smart open"),
        ["<leader>fp"] = mkbind(remote_plugins, "Remote plugins neocraft"),
        ["<leader>fs"] = mkbind(
            alternative(
                builtin.lsp_workspace_symbols,
                vim.lsp.buf.workspace_symbol
            ), "Workspace symbols"),
        ["<leader>fd"] = mkbind(
            alternative(
                builtin.lsp_document_symbols,
                vim.lsp.buf.document_symbol
            ),
            "Document symbols"),
        -- Split up search string to avoid showing up in search
        ["<leader>ft"] = mkbind(with(builtin.grep_string, { search = "TO" .. "DO" }), "TO" .. "DOs"),
        ["<leader>/"] = mkbind("<cmd>Telescope grep_buffer<cr>", "Grep in buffer"),
    })
end

-- @lsp.keybind
---@param opts { buffer: any }
function keybind_table.lsp(opts)
    nmap({
        ['gD'] = mkbind(vim.lsp.buf.declaration, "Go to declaration", opts),
        ['K'] = mkbind(vim.lsp.buf.hover, "Show hover info", opts),
        ['<C-k>'] = mkbind(vim.lsp.buf.signature_help, "Show signature help", opts),
        ['<space>wa'] = mkbind(vim.lsp.buf.add_workspace_folder, "Add workspace folder", opts),
        ['<space>wr'] = mkbind(vim.lsp.buf.remove_workspace_folder, "Remove workspace folder", opts),
        ['<space>wl'] = mkbind(
            function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end,
            "List workspace folders", opts
        ),
        ['<space>rn'] = mkbind(vim.lsp.buf.rename, "Rename symbol", opts),
        ['<F2>'] = mkbind(vim.lsp.buf.rename, "Rename symbol", opts),
        ['<space>f'] = mkbind("<cmd>FormatFile<cr>", "Format file", opts),
        ['<space>ca'] = mkbind(vim.lsp.buf.code_action, "Open code actions", opts),
        [''] = mkbind(vim.lsp.buf.code_action, "Open code actions", opts),
    })
end

function keybind_table.dap_enable()
    return {
        { "<leader>db", mode = "n", "<cmd>DapToggleBreakpoint<cr>", desc = "Toggle breakpoint", },
        {
            "<F5>",
            mode = "n",
            function()
                if vim.bo.filetype == "mylang" then
                    require("toggleterm").exec("./compile-and-run.sh " .. vim.api.nvim_buf_get_name(0))
                elseif vim.bo.filetype == "typescript" then
                    require("toggleterm").exec("bun " .. vim.api.nvim_buf_get_name(0))
                else
                    require("dap").continue()
                end
            end,
            desc = "Debug: Continue",
        },
    }
end

-- @dap.keybind
function keybind_table.dap()
    local dap = require("dap")
    local widgets = require("dap.ui.widgets")

    nmap({
        ["<F10>"] = mkbind("<cmd>DapStepOver<cr>", "Debug: Step Over"),
        ["<F11>"] = mkbind("<cmd>DapStepInto<cr>", "Debug: Step Into"),
        ["<F12>"] = mkbind("<cmd>DapStepOut<cr>", "Debug: Step Out"),
        ["K"] = mkbind(
            function()
                if (dap.session()) then
                    widgets.hover()
                end
            end,
            "Show hover info"),
    })
end

-- @rest.keybind
function keybind_table.rest()
    nmap({
        ["<leader>rs"] = "<Plug>RestNvim",
        ["<leader>rr"] = "<Plug>RestNvimLast",
        ["<leader>rp"] = "<Plug>RestNvimPreview",
    })
end

-- @tree.keybind
function keybind_table.tree()
    return {
        { "<leader>tt", mode = "n", "<cmd>NvimTreeFindFile<CR>", desc = "Tree: Find file" },
        { "<leader>tc", mode = "n", "<cmd>NvimTreeClose<CR>",    desc = "Tree: Close" },
    }
end

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local function cmp_standard_bindings(cmp)
    return {
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() and (cmp.get_selected_entry() == nil) then
                cmp.confirm({ select = true })
            elseif cmp.visible() then
                cmp.confirm({ select = true })
            elseif vim.fn["vsnip#available"](1) == 1 then
                feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { "i", "s" }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            local types = require("cmp.types")
            local start = cmp.get_selected_entry()
            while true do
                cmp.mapping.select_next_item()(fallback)
                local e = cmp.get_selected_entry()
                if (e == start or (e ~= nil and e.completion_item.kind == types.lsp.CompletionItemKind.Snippet)) then
                    break;
                end
            end
        end),
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }
end

local function cmp_insert_only_bindings(cmp)
    return {
        ['<C-s'] = cmp.mapping(function(fallback)
            if cmp.visible() or has_words_before() then
                cmp.complete({ config = { sources = { "vsnip" } } })
            else
                fallback()
            end
        end),
    }
end

-- @cmp.keybind
function keybind_table.cmp()
    local cmp = require("cmp")
    return cmp.mapping.preset.insert(vim.tbl_deep_extend("force", cmp_standard_bindings(cmp),
        cmp_insert_only_bindings(cmp)))
end

-- @cmp_cmdline.keybind
function keybind_table.cmp_cmdline()
    local cmp = require("cmp")
    return cmp.mapping.preset.cmdline(cmp_standard_bindings(cmp))
end

-- @treesitter.keybind
function keybind_table.treesitter()
    local ts_utils = require("nvim-treesitter.ts_utils")
    local telescope = require("telescope.builtin")

    ---@param fn fun(node: TSNode): nil
    local with_node = function(fn)
        return function()
            local node = ts_utils.get_node_at_cursor()
            if (node == nil) then return end
            fn(node)
        end
    end

    local function getTrimmedText(text)
        local spaceIndex = text:find(" ")
        if spaceIndex then
            local trimmedText = text:sub(0, spaceIndex - 1)
            return trimmedText
        else
            return text
        end
    end

    local util_maps = {
        ["<leader>ts"] = mkbind(
            with_node(function(node)
                ts_utils.update_selection(0, node, "charwise")
            end),
            "treesitter select node"
        ),
        ["<leader>th"] = mkbind(
            with_node(function(node)
                local text = getTrimmedText(vim.treesitter.get_node_text(node, 0))
                vim.cmd("help " .. text)
            end),
            "treesitter open help for node"
        ),
        ["<leader>tff"] = mkbind(with_node(function(node)
            local text = getTrimmedText(vim.treesitter.get_node_text(node, 0))
            telescope.find_files({ search_file = text, prompt_title = "Find Files (" .. text .. ")" })
        end), "treesitter open find files for node"),
        ["<leader>tfg"] = mkbind(with_node(function(node)
            local text = getTrimmedText(vim.treesitter.get_node_text(node, 0))
            telescope.grep_string({ search = text })
        end), "treesitter open grep for node"),
        ["<leader>tr"] = mkbind(function()
            vim.treesitter.stop()
            vim.treesitter.start()
            require("twilight").reset()
        end, "treesitter restart")
    }

    nmap(util_maps)
end

function keybind_table.treesitter_textobjects()
    local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"

    -- Repeat movement with ; and ,
    -- ensure ; goes forward and , goes backward regardless of the last direction
    vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
    vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

    return {
        select = {
            -- You can use the capture groups defined in textobjects.scm
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            -- You can also use captures from other query groups like `locals.scm`
            ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
            ["a#"] = "@comment.outer",
            ["i#"] = "@comment.inner",
        },
        swap = {
            swap_next = {
                ["<leader>a"] = "@parameter.inner",
            },
            swap_previous = {
                ["<leader>A"] = "@parameter.inner",
            },
        },
        move = {
            goto_next_start = {
                ["äm"] = "@function.outer",
                ["ää"] = { query = "@class.outer", desc = "Next class start" },
                --
                -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queires.
                --["äo"] = "@loop.*",
                ["äo"] = { query = { "@loop.inner", "@loop.outer" } },
                --
                -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
                -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
                ["äs"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
                ["äz"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
                ["äa"] = "@parameter.inner",
                ["öa"] = { query = { "@parameter.inner", "h" } },
            },
            goto_next_end = {
                ["äM"] = "@function.outer",
                ["äc"] = "@class.outer",
            },
            goto_previous_start = {
                ["Äm"] = "@function.outer",
                ["Äc"] = "@class.outer",
                ["Äs"] = { query = "@scope", query_group = "locals", desc = "Previous scope" },
                ["Äz"] = { query = "@fold", query_group = "folds", desc = "Previous fold" },
                ["Äa"] = "@parameter.inner",
            },
            goto_previous_end = {
                ["ÄM"] = "@function.outer",
                ["Ää"] = "@class.outer",
            },
            -- Below will go to either the start or the end, whichever is closer.
            -- Use if you want more granular movements
            -- Make it even more gradual by adding multiple queries and regex.
            goto_next = {
                ["äd"] = "@conditional.outer",
            },
            goto_previous = {
                ["Äd"] = "@conditional.outer",
            },
        },
    }
end

-- @terminal.keybind
function keybind_table.terminal()
    return {
        { "<F3>",  mode = { "t", "n" }, "<Cmd>ToggleTerm<CR>", desc = "Toggle terminal" },
        { "<Esc>", mode = "t",          "<C-\\><C-N>",         desc = "Close terminal" }
    }
end

-- @twilight.keybind
function keybind_table.twilight()
    nmap({ ["<leader>vw"] = "<cmd>Twilight<CR>" })
end

function keybind_table.daily_todo()
    local section = require("daily-todos.section")
    nmap({
        ["<Tab>"] = mkbind("/^\\s*-<CR>", "Go to next task"),
        ["<S-Tab>"] = mkbind("?^\\s*-<CR>", "Go to previous task"),
        ["<leader><Tab>"] = mkbind("<Cmd>DailyNext<CR>", "Go to next daily todos file"),
        ["<leader><S-Tab>"] = mkbind("<Cmd>DailyPrev<CR>", "Go to previous daily todos file"),
        ["<leader>d+"] = mkbind(function()
            section.section_add_item(section.Section.New, "- [ ] ")
        end, "Add new item"),
        ["<leader>d-"] = mkbind(function()
            local current_line = vim.fn.line('.')
            local current_section = section.get_section(current_line)
            if current_section == nil then error("Not in a section") end
            section.section_remove_item(section.Section.New, current_line)
        end, "Add new item"),
        ["<leader>dm"] = mkbind("<Cmd>DailyMoveToNext<CR>", "Move item to next daily todos entry file"),
        ["<leader>dt"] = mkbind("<Cmd>DailyToggleTaskDone<CR>", "Toggle selected task"),
        ["<Enter>"] = mkbind("<Cmd>DailyToggleTaskDone<CR>", "Toggle selected task"),
        ["<leader>ds"] = mkbind("<Cmd>DailyStandupView<CR>", "Standup view mode"),
    })
end

function keybind_table.diffview()
    local actions = require("diffview.actions")
    local actions_focus_files_mapping = {
        { "n", "<Esc>", actions.focus_files, { desc = "Close diffview", silent = true, nowait = true } }
    }
    local actions_close_mapping = {
        { "n", "<Esc>", actions.close, { desc = "Close diffview", silent = true, nowait = true } }
    }
    local diffview_close_mapping = {
        { "n", "<Esc>", "<Cmd>DiffviewClose<CR>", { desc = "Close diffview", silent = true, nowait = true } }
    }

    return {
        view = actions_focus_files_mapping,
        file_panel = diffview_close_mapping,
        diff1 = actions_focus_files_mapping,
        diff2 = actions_focus_files_mapping,
        diff3 = actions_focus_files_mapping,
        diff4 = actions_focus_files_mapping,
        option_panel = actions_close_mapping,
        help_panel = actions_close_mapping,
        file_history_panel = diffview_close_mapping,
    }
end

function keybind_table.flash()
    return {
        { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
        { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
        { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
        { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
        { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
    }
end

function keybind_table.outline()
    return {
        {
            -- TODO: seems to be a bit unstable if toggling while the lsp is starting
            "<leader>o",
            function()
                local enabled = not vim.api.nvim_get_var("outline_enabled")
                vim.api.nvim_set_var("outline_enabled", enabled)
                if enabled then
                    vim.cmd [[silent! OutlineOpen!]]
                    vim.cmd [[silent! OutlineFollow!]]
                else
                    vim.cmd [[silent! OutlineClose]]
                end
            end,
            desc = "Toggle outline",
        },
    }
end

function keybind_table.perfanno()
    return {
        { mode = "n", "<LEADER>plf", ":PerfLoadFlat<CR>",                desc = "Flat",                      noremap = true, silent = true },
        { mode = "n", "<LEADER>plg", ":PerfLoadCallGraph<CR>",           desc = "Call graph",                noremap = true, silent = true },
        { mode = "n", "<LEADER>plo", ":PerfLoadFlameGraph<CR>",          desc = "Flame graph",               noremap = true, silent = true },

        { mode = "n", "<LEADER>pe",  ":PerfPickEvent<CR>",               desc = "Pick event",                noremap = true, silent = true },
        { mode = "n", "<LEADER>pa",  ":PerfAnnotate<CR>",                desc = "Annotate",                  noremap = true, silent = true },
        { mode = "n", "<LEADER>pf",  ":PerfAnnotateFunction<CR>",        desc = "Annotate function",         noremap = true, silent = true },
        { mode = "v", "<LEADER>pa",  ":PerfAnnotateSelection<CR>",       desc = "Annotate selection",        noremap = true, silent = true },

        { mode = "n", "<LEADER>pt",  ":PerfToggleAnnotations<CR>",       desc = "Toggle annotations",        noremap = true, silent = true },

        { mode = "n", "<LEADER>ph",  ":PerfHottestLines<CR>",            desc = "Hottest lines",             noremap = true, silent = true },
        { mode = "n", "<LEADER>ps",  ":PerfHottestSymbols<CR>",          desc = "Hottest symbols",           noremap = true, silent = true },
        { mode = "n", "<LEADER>pc",  ":PerfHottestCallersFunction<CR>",  desc = "Hottest callers function",  noremap = true, silent = true },
        { mode = "v", "<LEADER>pc",  ":PerfHottestCallersSelection<CR>", desc = "Hottest callers selection", noremap = true, silent = true },
    }
end

function keybind_table.twitch()
    return nmap({
        ["<leader>sc"] = mkbind("<Cmd>TwitchChatToggle<CR>", "Toggle Twitch Chat floating window"),
    })
end

function keybind_table.ai()
    local ai = require("ai");

    nmap({
        ["<leader>ce"] = mkbind(function()
            ai.prompt_codex_exec({ prompt = "Codex prompt: " })
        end, "Codex: prompt CodexExec")
    })
    vmap({
        ["<leader>ce"] = mkbind(function()
            local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
            vim.api.nvim_feedkeys(esc, "nx", false)
            vim.schedule(function()
                ai.prompt_codex_exec({
                    prompt = "Codex prompt (selection): ",
                    range = "visual",
                })
            end)
        end, "Codex: prompt CodexExec with selection")
    })
end

return {
    hooks = keybind_table,
}
