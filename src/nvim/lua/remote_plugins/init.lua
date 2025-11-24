local M = {}

function M.setup()
    local cache = require("remote_plugins.cache")
    local update = require("remote_plugins.update")

    cache.setup()
    update.setup()

    -- Initial update index
    if (cache.exists() == 0) then
        update.update_index()
    end
end

return M
