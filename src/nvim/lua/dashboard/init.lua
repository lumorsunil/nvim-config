local M = {}

---@class DashboardOptions
---@field actions DashboardAction[]

---@class DashboardAction
---@field command string
---@field label string
---@field key string

local function show_dashboard()
    vim.bo.buftype = "nofile"
    vim.bo.modifiable = true
    local ns_id = vim.api.nvim_create_namespace('Dashboard')
    local menu_offset = 10
    local x = math.max(math.floor(vim.fn.winwidth(0) / 2) - 10, 1)
    --vim.api.nvim_buf_set_extmark(0, ns_id, menu_offset, x, {})
    --vim.fn.cursor({ menu_offset, x })
    --vim.api.nvim_put({ "[r] - Open recent..." }, "V", false, false)
    --vim.fn.cursor({ menu_offset + 2, x })
    --vim.api.nvim_put({ "[f] - Open file..." }, "V", false, false)
    --vim.fn.cursor({ menu_offset + 4, x })
    --vim.api.nvim_put({ "[g] - Grep..." }, "V", false, false)
    vim.bo.modifiable = false
end

---@param opts DashboardOptions
function M.setup(opts)
    local group = vim.api.nvim_create_augroup("Dashboard", {})
    vim.api.nvim_create_autocmd("BufEnter", {
        group = group,
        pattern = { "*" },
        once = true,
        callback = function()
            if vim.fn.argc() == 0 then
                show_dashboard()
            end
        end
    })
end

return M
