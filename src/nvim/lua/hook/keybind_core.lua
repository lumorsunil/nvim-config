local M = {}

---@alias KeybindAction string|fun()
---@alias KeybindDef KeybindAction|{ action: KeybindAction, opts: table }
---@alias KeybindTable table<string, KeybindDef>

---@param mode string
---@param bindings KeybindTable
---@param opts? table|nil
local function _map(mode, bindings, opts)
    for k, v in pairs(bindings) do
        local bind
        opts = (opts == nil and {}) or opts
        if (type(v) == "table") then
            bind = v.action
            opts = vim.tbl_deep_extend("force", opts, v.opts)
        else
            bind = v
        end
        vim.keymap.set(mode, k, bind, opts)
    end
end

---@param bindings KeybindTable
---@param opts? table|nil
local function nmap(bindings, opts)
    _map('n', bindings, opts)
end

---@param bindings KeybindTable
---@param opts? table|nil
local function imap(bindings, opts)
    _map('i', bindings, opts)
end

---@param bindings KeybindTable
---@param opts? table|nil
local function vmap(bindings, opts)
    _map('v', bindings, opts)
end

---@param bindings KeybindTable
---@param opts? table|nil
local function omap(bindings, opts)
    _map('o', bindings, opts)
end

---@param bindings KeybindTable
---@param opts? table|nil
local function tmap(bindings, opts)
    _map('t', bindings, opts)
end

---@param action KeybindAction
---@param desc string
---@param opts? table|nil
---@return KeybindDef
local function mkbind(action, desc, opts)
    return { action = action, opts = vim.tbl_deep_extend("force", opts == nil and {} or opts, { desc = desc }) }
end

M.nmap = nmap
M.vmap = vmap
M.imap = imap
M.omap = omap
M.tmap = tmap
M.mkbind = mkbind

return M
