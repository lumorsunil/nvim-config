local pms_run = require('pms.run')
local pms_list = require('pms.list')
local pms_complete = require('pms.complete')

local M = {}

function M.register_commands()
    vim.api.nvim_create_user_command("PmsRun", function(opts)
        local script_label = opts.args
        pms_run.run(script_label)
    end, {
        nargs = 1,
        complete = pms_run.mk_complete_fn(),
    })

    vim.api.nvim_create_user_command("PmsRestart", function(opts)
        local script_label = opts.args
        pms_run.restart(script_label)
    end, {
        nargs = 1,
        complete = pms_complete.mk_complete_fn(function() return require("pms.terminal").get_running() end),
    })

    vim.api.nvim_create_user_command("PmsAdd", function(opts)
        if (#(opts.fargs) < 2) then
            error("PmsAdd requires 2+ arguments: label [...command]")
        end
        local command = vim.fn.join(vim.list_slice(opts.fargs, 2), " ")
        M.add_custom_script(opts.fargs[1], command)
    end, {
        nargs = "+",
    })

    vim.api.nvim_create_user_command("PmsList", function()
        pms_list.print_scripts()
    end, {})
end

return M
