return function()
    local overseer = require("overseer");
    overseer.setup({});

    --local hasZigTask = false;
    local function zig()
        --if hasZigTask then return end
        local task = overseer.new_task({
            cmd = { "zig" },
            name = "zig compiler errors",
            args = {
                "build", "-freference-trace",
            },
            components = {
                --{ "restart_on_save", delay = 1, },
                {
                    "on_output_parse",
                    parser = {
                        diagnostics = {
                            {
                                "extract",
                                "^(.*):(%d+):(%d+):%s*(%a+):%s*(.*)$",
                                "filename",
                                "lnum",
                                "col",
                                "type",
                                "text",
                                "code"
                            },
                        }
                    }
                },
                {
                    "display_duration",
                    detail_level = 2,
                },
                {
                    "on_output_summarize",
                    max_lines = 4,
                },
                {
                    "on_exit_set_status",
                    success_codes = {},
                },
                {
                    "on_complete_dispose",
                    timeout = 300,
                    statuses = { "SUCCESS", "FAILURE", "CANCELED" },
                    require_view = { "SUCCESS", "FAILURE" }
                },
                {
                    "on_result_diagnostics",
                    remove_on_restart = true,
                },
                {
                    "restart_on_save",
                    delay = 1,
                }
            }
        })

        --hasZigTask = true

        task:start()
    end

    -- vim.api.nvim_create_autocmd("BufWritePost", {
    --     pattern = { "*.zig", "*.zig.zon" },
    --     once = true,
    --     callback = zig
    -- })

    --    if vim.bo.filetype == "zig" then
    --        zig()
    --    else
    --        vim.api.nvim_create_autocmd("BufRead", {
    --            pattern = { "*.zig", "*.zig.zon" },
    --            once = true,
    --            callback = zig
    --        })
    --    end
end
