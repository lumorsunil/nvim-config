local pms = require('pms.pms')

local M = {}

---@alias PMSScriptList { scripts: table<string, string> }
---@alias PMSScriptLists table<string, PMSScriptList>

---@param header string
---@param script_lists PMSScriptLists
local function add_script_list(header, script_lists)
    local script_list = {
        scripts = {}
    }

    script_lists[header] = script_list

    return script_list
end

---@param script_list PMSScriptList
---@param label string
---@param command string
local function add_script(script_list, label, command)
    script_list.scripts[label] = command
end

---@param script_lists PMSScriptLists
local function add_custom_scripts(script_lists)
    if #pms.pms.custom_scripts > 0 then
        local script_list = add_script_list("Custom scripts", script_lists)

        for k, s in pairs(pms.pms.custom_scripts) do
            add_script(script_list, k, s.command)
        end
    end
end

---@param script_lists PMSScriptLists
---@param package_info PackageInfo
local function add_package_info_scripts(script_lists, package_info)
    local script_list = add_script_list("Scripts from " .. package_info.type, script_lists)

    for k, s in pairs(package_info.scripts) do
        add_script(script_list, k, s)
    end
end

---@param script_lists PMSScriptLists
local function add_package_infos(script_lists)
    for _, package_info in ipairs(pms.pms.package_infos) do
        add_package_info_scripts(script_lists, package_info)
    end
end

---@param script_lists PMSScriptLists
local function create_message(script_lists)
    local message = ""

    for header, script_list in pairs(script_lists) do
        message = message .. header .. ":\n\n"

        for label, command in pairs(script_list.scripts) do
            message = message .. label .. " -> " .. command .. "\n"
        end

        message = message .. "\n\n"
    end

    return message
end

function M.print_scripts()
    ---@type PMSScriptLists
    local script_lists = {}

    add_custom_scripts(script_lists)
    add_package_infos(script_lists)

    local message = create_message(script_lists)

    vim.api.nvim_echo({ { message, "Normal" } }, true, {})
end

return M
