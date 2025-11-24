local pms = require("pms.pms")
local pms_package_info = require("pms.package_info")
local pms_commands = require("pms.commands")

local M = {}

---@module "pms.terminal"

local function register_scripts()
    local root_package_info = pms_package_info.get_package_info()
    if root_package_info then pms.add_package_info(root_package_info) end
end

local function setup()
    require("pms.terminal").setup()
    register_scripts()
    pms_commands.register_commands()
end

M.add_custom_script = require("pms.custom_script").add_custom_script

---@alias PMSScript { label: string; command: string; executable: string; }
---@return PMSScript[]
function M.get_package_scripts()
    ---@type PMSScript[]
    local scripts = {}

    for _, package_info in ipairs(pms.pms.package_infos) do
        for label, command in pairs(package_info.scripts) do
            ---@type PMSScript
            local script = { label = label, command = command, executable = package_info.executable }
            table.insert(scripts, script)
        end
    end

    return scripts
end

function M.setup()
    if vim.api.nvim_get_vvar("vim_did_enter") then
        setup()
    else
        local group = vim.api.nvim_create_augroup("PMS", {})
        vim.api.nvim_create_autocmd("VimEnter", {
            group = group,
            once = true,
            callback = function()
                setup()
                vim.api.nvim_del_augroup_by_id(group)
            end,
        })
    end
end

return M
