local hook_table = {}
local hooks_called_table = {}

---@param key string
---@param fn fun(): nil
---@return string | nil
local function register_hook(key, fn)
    if (hook_table[key]) then
        return "hook '" .. key "' already registered"
    end

    hook_table[key] = fn
    hooks_called_table[key] = false
end

---@param key string
---@param opts? any
---@return string | nil
local function call_hook(key, opts)
    if (hook_table[key] == nil) then
        error("hook '" .. key "' not registered")
        return
    end

    if (hooks_called_table[key]) then
        error("hook '" .. key "' already called")
    end

    hook_table[key](opts)
    hooks_called_table[key] = true
end

---@return table<integer, string>
local function check_hooks()
    local hooks_not_called = {}

    for k,_ in pairs(hook_table) do
        if (hooks_called_table[k] == false) then
            table.insert(hooks_not_called, k)
        end
    end

    return hooks_not_called
end

return {
    register_hook = register_hook,
    call_hook = call_hook,
    check_hooks = check_hooks,
}
