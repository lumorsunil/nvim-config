local pms = require('pms.pms')
local json = require('pms.json')

local M = {}

local supported_package_files = { packageJson = "package.json" }

---@param package_file string
---@return PackageInfo|nil
local function to_package_info(package_file)
    local basename = vim.fn.fnamemodify(package_file, ":t")

    if basename == supported_package_files.packageJson then
        local scripts_string = vim.fn.system("cat '" ..
            package_file .. "' | jq '.scripts'")
        local package_manager = vim.fn.system("cat '" ..
            package_file .. "' | jq '.packageManager' -r")
        local scripts = json.parse_flat_json_object(scripts_string)
        local executable = vim.fn.matchstr(package_manager, '[^@]\\+')
        return {
            type = supported_package_files.packageJson,
            executable = executable .. " run",
            source_path = package_file,
            scripts = scripts,
        }
    end

    return nil
end

---@param dir string
---@return PackageInfo|nil
function M.get_package_info_by_dir(dir)
    dir = vim.fn.fnamemodify(dir, ":.")
    for _, package_info in ipairs(pms.pms.package_infos) do
        if vim.fn.fnamemodify(package_info.source_path, ":.:h") == dir then
            return package_info
        end
    end
end

---@param dir? string
local function find_package_file(dir)
    dir = dir or "."
    for _, v in pairs(supported_package_files) do
        local p = dir .. "/" .. v
        if vim.fn.filereadable(p) then
            return vim.fn.fnamemodify(p, ":p")
        end
    end

    return nil
end

---@param dir? string
function M.get_package_info(dir)
    local packageFile = find_package_file(dir)
    if not packageFile then return end
    return to_package_info(packageFile)
end

---@param dir string
function M.add_package_info_by_dir(dir)
    local package_info = M.get_package_info(dir)
    if not package_info then
        return
    end
    pms.add_package_info(package_info)
end

return M
