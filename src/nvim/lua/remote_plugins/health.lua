local health = vim.health
local cache = require("remote_plugins.cache")

return {
    check = function()
        health.report_start("remote_plugins report")
        local cache_exists = cache.exists()

        if (cache_exists == 0) then
            health.report_error("cache index not populated")
        elseif (vim.fn.executable("wslview") == 0) then
            health.report_error("wslview command not found, cannot open urls")
        else
            health.report_ok(":)")
        end
    end
}
