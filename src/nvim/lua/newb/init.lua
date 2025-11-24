local M = {}

function M.setup()
    local group = vim.api.nvim_create_augroup("NewbLang", {})
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        group = group,
        pattern = { "*.newb" },
        callback = function()
            vim.cmd.setfiletype("newb")
        end
    })
    vim.api.nvim_create_autocmd("Syntax", {
        group = group,
        pattern = { "*.newb" },
        callback = function()
            vim.cmd [[runtime! syntax/newb.vim]]
        end
    })

    local overseer = require('overseer')

    overseer.register_template({
        -- Required fields
        name = "NewbLang Check",
        builder = function()
            -- This must return an overseer.TaskDefinition
            return {
                -- cmd is the only required field
                cmd = { 'zig' },
                -- additional arguments for the cmd
                args = { "build", "run", "-freference-trace" },
                -- the name of the task (defaults to the cmd of the task)
                name = "Build",
                -- set the working directory for the task
                --cwd = "/tmp",
                -- additional environment variables
                -- env = {
                --     VAR = "FOO",
                -- },
                -- the list of components or component aliases to add to the task
                components = {
                    {
                        "on_output_parse",
                        parser = {
                            -- Put the parser results into the 'diagnostics' field on the task result
                            diagnostics = {
                                -- Extract fields using lua patterns
                                -- To integrate with other components, items in the "diagnostics" result should match
                                -- vim's quickfix item format (:help setqflist)
                                -- newb error at in.newb:1,9 Expected char '+', actual: ;
                                { "extract", "^newb error at ([^%s].+):(%d+),(%d+) (.+)$", "filename", "lnum", "col", "text" },
                            }
                        }
                    },
                    { "on_result_diagnostics", remove_on_restart = true },
                    "default",
                },
                -- arbitrary table of data for your own personal use
                -- metadata = {
                --     foo = "bar",
                -- },
            }
        end,
        -- Optional fields
        desc = "Compiles the .newb file.",
        -- Tags can be used in overseer.run_template()
        tags = { overseer.TAG.BUILD },
        params = {
            -- See :help overseer-params
        },
        -- Determines sort order when choosing tasks. Lower comes first.
        priority = 50,
        -- Add requirements for this template. If they are not met, the template will not be visible.
        -- All fields are optional.
        condition = {
            -- A string or list of strings
            -- Only matches when current buffer is one of the listed filetypes
            filetype = { "newb" },
            -- A string or list of strings
            -- Only matches when cwd is inside one of the listed dirs
            -- dir = "/home/user/my_project",
            -- Arbitrary logic for determining if task is available
            -- callback = function(search)
            --     print(vim.inspect(search))
            --     return true
            -- end,
        },
    })

    vim.api.nvim_create_autocmd("BufEnter", {
        group = group,
        pattern = { "*.newb" },
        once = true,
        callback = function()
            overseer.run_template(
                {
                    name = "NewbLang Check",
                    first = true,
                    prompt = "never",
                },
                function(task)
                    if (task) then
                        task:add_component({ "restart_on_save", paths = { vim.fn.expand("%:p") } })
                    end
                end
            )
        end
    })
end

return M
