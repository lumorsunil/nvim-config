local pms = require "pms.pms"

local M = {}

---@param label string
---@param command string
function M.add_custom_script(label, command)
    if pms.pms.custom_scripts[label] then
        error("script " .. label .. " already defined")
    end
    pms.pms.custom_scripts[label] = { command = command }
end

return M
