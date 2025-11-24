local health = vim.health
local hook = require("hook")

return {
    check = function()
        health.report_start("hook report")
        local errors = hook.check_hooks()

        if (table.maxn(errors) > 0) then
            health.report_error("hooks not called: " .. table.concat(errors, ', '))
        else
            health.report_ok(":)")
        end
    end
}
