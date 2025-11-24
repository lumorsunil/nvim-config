local M = {}

---@class PMS
---@field package_infos PackageInfo[]
---@field custom_scripts table<string, CustomScript>

---@class PackageInfo
---@field type string
---@field executable string
---@field source_path string
---@field scripts table<string, string>

---@class CustomScript
---@field command string

---@return PMS
local function mk_pms()
    return {
        package_infos = {},
        custom_scripts = {},
    }
end

---@param package_info PackageInfo
function M.add_package_info(package_info)
    table.insert(M.pms.package_infos, package_info)
end

---@type PMS
M.pms = mk_pms()

return M
