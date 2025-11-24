local pms = require("pms.pms")
local pms_package_info = require("pms.package_info")
local pms_complete = require("pms.complete")

local M = {}

local custom_prefix = "custom:"

---@param script_label string
function M.run(script_label)
    local label, dir, command
    if vim.startswith(script_label, custom_prefix) then
        label = string.sub(script_label, #custom_prefix + 1, #script_label)
        command = pms.pms.custom_scripts[label].command
    else
        label = vim.fn.fnamemodify(script_label, ":t")
        dir = vim.fn.fnamemodify(script_label, ":h")
        local package_info = pms_package_info.get_package_info_by_dir(dir)
        if not package_info then error("package info for " .. dir .. " not found") end
        command = package_info.executable .. " " .. label
    end
    require("pms.terminal").run_script(label, { command = command, cwd = dir })
end

function M.mk_complete_fn()
    return pms_complete.mk_complete_fn(function()
        local items = {}
        for label, _ in pairs(pms.pms.custom_scripts) do
            table.insert(items, custom_prefix .. label)
        end
        for _, package_info in ipairs(pms.pms.package_infos) do
            local prefix = vim.fn.fnamemodify(package_info.source_path, ":.:h") .. "/"
            if prefix == "./" then prefix = "" end
            for label, _ in pairs(package_info.scripts) do
                local item = prefix .. label
                table.insert(items, item)
            end
        end
        return items
    end)
end

---@param script_label string
function M.restart(script_label)
    require("pms.terminal").restart_script(script_label)
end

return M
