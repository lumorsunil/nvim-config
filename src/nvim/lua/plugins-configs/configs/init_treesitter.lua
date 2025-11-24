return function()
    local keybinds = require("hook.keybind").hooks
    local textobjectsmaps = keybinds.treesitter_textobjects()
    require('nvim-treesitter.configs').setup({
        modules = {},
        ensure_installed = { "http", "json" },
        sync_install = false,
        ignore_install = {},
        auto_install = true,
        highlight = {
            enabled = true,
        },
        textobjects = {
            select = {
                enable = true,

                -- Automatically jump forward to textobj, similar to targets.vim
                lookahead = true,

                keymaps = textobjectsmaps.select,
                -- You can choose the select mode (default is charwise 'v')
                --
                -- Can also be a function which gets passed a table with the keys
                -- * query_string: eg '@function.inner'
                -- * method: eg 'v' or 'o'
                -- and should return the mode ('v', 'V', or '<c-v>') or a table
                -- mapping query_strings to modes.
                selection_modes = {
                    ['@parameter.outer'] = 'v', -- charwise
                    ['@function.outer'] = 'V',  -- linewise
                    ['@class.outer'] = '<c-v>', -- blockwise
                },
                -- If you set this to `true` (default is `false`) then any textobject is
                -- extended to include preceding or succeeding whitespace. Succeeding
                -- whitespace has priority in order to act similarly to eg the built-in
                -- `ap`.
                --
                -- Can also be a function which gets passed a table with the keys
                -- * query_string: eg '@function.inner'
                -- * selection_mode: eg 'v'
                -- and should return true of false
                include_surrounding_whitespace = true,
            },
            swap = {
                enable = true,
                swap_next = textobjectsmaps.swap.swap_next,
                swap_previous = textobjectsmaps.swap.swap_previous,
            },
            move = {
                enable = true,
                set_jumps = true, -- whether to set jumps in the jumplist
                goto_next_start = textobjectsmaps.move.goto_next_start,
                goto_next_end = textobjectsmaps.move.goto_next_end,
                goto_previous_start = textobjectsmaps.move.goto_previous_start,
                goto_previous_end = textobjectsmaps.move.goto_previous_end,
                goto_next = textobjectsmaps.move.goto_next,
                goto_previous = textobjectsmaps.move.goto_previous,
            },
        },
    })
    --require 'treesitter-context'.setup {
    --    enable = true,      -- Enable this plugin (Can be enabled/disabled later via commands)
    --    max_lines = 0,      -- How many lines the window should span. Values <= 0 mean no limit.
    --    min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
    --    line_numbers = true,
    --    multiline_threshold = 20, -- Maximum number of lines to show for a single context
    --    trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
    --    mode = 'cursor',    -- Line used to calculate context. Choices: 'cursor', 'topline'
    --    -- Separator between context and content. Should be a single character string, like '-'.
    --    -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
    --    separator = nil,
    --    zindex = 20, -- The Z-index of the context window
    --    on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
    --}
    keybinds.treesitter()
    vim.api.nvim_create_augroup("TreesitterContext", {})
    vim.api.nvim_create_autocmd({ "BufReadPost" }, {
        pattern = { "*" },
        callback = function()
            vim.cmd [[TSEnable highlight]]
            --vim.cmd [[TSContextEnable]]
        end
    })
end
