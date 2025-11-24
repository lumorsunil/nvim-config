return require("telescope").register_extension({
    setup = function()
    end,
    exports = {
        grep_buffer = function(opts)
            local bufnr = vim.fn.bufnr()
            local entries = {}
            for i = 1, vim.fn.line('$'), 1 do
                local content = vim.fn.getline(i)
                entries[i] = {
                    content = content,
                    lnum = i,
                    bufnr = bufnr
                }
            end
            return require("telescope.pickers").new(opts, {
                prompt_title = "grep buffer",
                finder = require("telescope.finders").new_table({
                    results = entries,
                    entry_maker = function(entry)
                        return {
                            value = entry,
                            display = entry.content,
                            ordinal = entry.content,
                            lnum = entry.lnum,
                            bufnr = entry.bufnr,
                        }
                    end
                }),
                sorter = require("telescope.config").values.generic_sorter(opts),
                previewer = require("telescope.previewers").new_buffer_previewer({
                    define_preview = function(self, entry, _)
                        vim.fn.setbufline(self.state.bufnr, 1, entry.display)
                    end,
                }),
                attach_mappings = function(prompt_bufnr, _)
                    local actions = require("telescope.actions")
                    local action_state = require("telescope.actions.state")
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()
                        vim.cmd(vim.fn.printf("buffer %d", selection.bufnr))
                        vim.cmd(vim.fn.printf("%d", selection.lnum))
                        vim.cmd [[silent normal! zz]]
                    end)
                    return true
                end,
            }):find()
        end
    },
    health = require("remote_plugins.health").check
})
