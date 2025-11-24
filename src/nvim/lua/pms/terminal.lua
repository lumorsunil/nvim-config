local M = {}

---@class RunOpts
---@field command string
---@field cwd? string
---@field split? "new" | "vnew"
---@field split_location? "aboveleft" | "leftabove" |  "belowright" | "rightbelow" | "botright" | "topleft"

---@class PmsTerminalsState
---@field terminal_tab? number|nil
---@field terminal_buffers table<string, number>
---@field terminal_running table<string, boolean>
---@field terminal_opts table<string, RunOpts>
---@field to_start table<string, RunOpts>
local _state = {
    terminal_tab = nil,
    terminal_buffers = {},
    terminal_running = {},
    terminal_opts = {},
    to_start = {},
}

local function initialize_tab()
    vim.cmd.tabnew()
    _state.terminal_tab = vim.fn.tabpagenr()
    vim.cmd.tabnext(-1)
end

---@return boolean
local function tab_exists()
    if not _state.terminal_tab then return false end
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        if tab == _state.terminal_tab then return true end
    end
    return false
end

---@return integer, boolean
local function get_or_set_tab()
    if tab_exists() then return _state.terminal_tab, false end
    initialize_tab()
    if _state.terminal_tab then return _state.terminal_tab, true end
    error("Could not initialize tab")
end

---@param label string
local function initialize_buffer(label)
    local buf = vim.api.nvim_create_buf(false, true)
    _state.terminal_buffers[label] = buf
end

---@param label string
---@return integer
local function get_or_set_buffer(label)
    local stored = _state.terminal_buffers[label]
    if not stored then initialize_buffer(label) end
    return _state.terminal_buffers[label]
end

---@param label string
local function is_running(label)
    return _state.terminal_running[label]
end

---@param buf integer
local function is_pms_buf(buf)
    for _, b in pairs(_state.terminal_buffers) do
        if buf == b then return true end
    end
    return false
end

---@param wins integer[]
---@param buf integer
local function find_buffer_window(wins, buf)
    --local tabinfo = vim.fn.gettabinfo(tab)
    --if not tabinfo or not tabinfo[1] then return end
    --local wins = tabinfo[1].windows
    for _, win in ipairs(wins) do
        local winbuf = vim.api.nvim_win_get_buf(win)
        if winbuf == buf then
            vim.fn.win_gotoid(win)
            return buf
        end
    end
end

---@param tab integer
---@param buf integer
---@param opts RunOpts|nil
local function bring_buffer_into_view_inner(tab, buf, opts)
    -- check if buffer already is in an existing window
    -- then go to that window and return
    local wins = vim.api.nvim_tabpage_list_wins(tab)
    if find_buffer_window(wins, buf) then return buf end

    -- check if we only have the initial window (happens at first run)
    -- then just set the buffer on that window and return
    if #wins == 1 then
        local win = wins[1]
        local winbuf = vim.api.nvim_win_get_buf(win)
        if not is_pms_buf(winbuf) then
            vim.api.nvim_win_set_buf(win, buf)
            vim.cmd.bdelete(winbuf)
            return buf
        end
    end

    if not opts then return end

    -- no existing window found, create a new window for the buffer
    if not opts.split then opts.split = "new" end
    if not opts.split_location then opts.split_location = "belowright" end
    vim.cmd(opts.split_location .. " " .. opts.split .. " buffer " .. buf)
end

---Goes to the buffer associated with the label, creates it if needed, and returns the bufnr.
---@param label string
---@param opts RunOpts|nil
---@param callback fun(buf: integer)
local function bring_buffer_into_view(label, opts, callback)
    local buf = get_or_set_buffer(label)
    local tab, did_initialize = get_or_set_tab()

    if not did_initialize then
        bring_buffer_into_view_inner(tab, buf, opts)
        callback(buf)
    else
        vim.api.nvim_create_autocmd("TabEnter", {
            once = true,
            callback = function()
                bring_buffer_into_view_inner(tab, buf, opts)
                callback(buf)
            end
        })

        vim.cmd.tabnext(tab)
    end
end

---@param label string
---@param callback function
function M.terminate_buffer(label, callback)
    if not is_running(label) then
        return
    end
    local buf = get_or_set_buffer(label)
    bring_buffer_into_view(label, nil, function()
        vim.api.nvim_create_autocmd("TermClose", {
            buffer = buf,
            once = true,
            callback = function()
                vim.cmd([[bdelete! ]] .. buf)
                _state.terminal_running[label] = false
                _state.terminal_buffers[label] = nil

                callback()
            end
        })

        vim.cmd.startinsert()
        vim.cmd.call [[feedkeys("\<C-c>\<Esc>")]]
    end)
end

---@param buf integer
---@return string|nil
local function get_label_from_buf(buf)
    for label, b in pairs(_state.terminal_buffers) do
        if b == buf then return label end
    end
end

---@param label string
---@param opts RunOpts
function M.run_script(label, opts)
    if is_running(label) then
        return
    end
    local command = opts.command
    if opts.cwd then command = "cd " .. opts.cwd .. " && " .. command end
    bring_buffer_into_view(label, opts, function()
        vim.cmd([[terminal ]] .. command)
        _state.terminal_running[label] = true
        _state.terminal_opts[label] = opts
    end)
end

function M.restart_script(label)
    local opts = _state.terminal_opts[label]
    if not opts then error("No command associated with label " .. label) end
    M.terminate_buffer(label, function()
        M.run_script(label, opts)
    end)
end

function M.get_running()
    ---@type string[]
    local running = {}
    for label, value in pairs(_state.terminal_running) do
        if value then table.insert(running, label) end
    end
    return running
end

function M.setup()
    local group = vim.api.nvim_create_augroup("PmsTerminal", {})
    vim.api.nvim_create_autocmd("TermClose", {
        group = group,
        callback = function()
            local abuf = tonumber(vim.fn.expand('<abuf>'))
            if not abuf then return end
            local label = get_label_from_buf(abuf)
            if not label then return end
            _state.terminal_running[label] = false
            vim.cmd [[checktime]]
        end
    })
    vim.api.nvim_create_autocmd("BufDelete", {
        group = group,
        callback = function()
            local abuf = tonumber(vim.fn.expand('<abuf>'))
            if not abuf then return end
            local label = get_label_from_buf(abuf)
            if not label then return end
            _state.terminal_buffers[label] = nil
        end
    })
end

return M
