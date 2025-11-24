local M = {}

local function array_includes(arr, val)
    for _, x in ipairs(arr) do
        if (x == val) then
            return true
        end
    end
    return false
end

function M.generate_results()
    local cache = require("remote_plugins.cache")
    local lines = cache.read()
    local filteredLines = {}

    for _, line in ipairs(lines) do
        if (not array_includes(line.plugin.tags, "preconfigured-configuration")) then
            table.insert(filteredLines, line)
        end
    end

    return filteredLines
end

return M
