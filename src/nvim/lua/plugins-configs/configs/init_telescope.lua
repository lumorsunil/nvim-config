return function()
    -- @telescope
    local telescope = require("telescope")

    telescope.setup({
        extensions = {
            ["ui-select"] = {
                require("telescope.themes").get_dropdown()
            },
            fzf = {
                fuzzy = true,                   -- false will only do exact matching
                override_generic_sorter = true, -- override the generic sorter
                override_file_sorter = true,    -- override the file sorter
                case_mode = "smart_case",       -- or "ignore_case" or "respect_case", the default case_mode is "smart_case"
            },
        }
    })
    telescope.load_extension("fzf")

    vim.api.nvim_create_autocmd("User", {
        pattern = { "InitAllDone" },
        once = true,
        callback = function()
            telescope.load_extension("remote_plugins")
            telescope.load_extension("ui-select")
            telescope.load_extension("easypick")
            telescope.load_extension("grep_buffer")
        end
    })

    require("hook.keybind").hooks.telescope()

    vim.api.nvim_create_autocmd("User", {
        pattern = "TelescopePreviewerLoaded",
        callback = function(_)
            vim.wo.wrap = true
        end,
    })
end
