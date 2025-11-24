-- Module that enables fast short-context-switching by pressing <S-Tab> to open
-- a window that shows a stack of previous locations/buffers/marks that has been used recently.
-- Pressing <S-Tab> or <Tab> while in this window will highlight the next/prev item in the list.
-- Pressing <Space> in this window will go to the location and push the selected location to the top of the stack.
local M = {}

local max_stack_size = 10
local max_bufname_length = 60

---@class SCSLocation
---@field winid integer
---@field bufnr integer
---@field line integer
---@field column integer

---@type SCSLocation[]
local stack = {}

---@type SCSLocation[]
local harpooned = {}

---@param a SCSLocation | nil
---@param b SCSLocation | nil
local function are_locations_equal(a, b)
    return (not a and not b) or (a and b and a.winid == b.winid and a.bufnr == b.bufnr)
end

---@param location SCSLocation
local function get_index(location)
    for i, l in ipairs(stack) do
        if are_locations_equal(location, l) then return i end
    end
    return -1
end

---@param location SCSLocation
local function go_to_location(location)
    vim.fn.win_gotoid(location.winid)
    if location.bufnr == vim.fn.bufnr() then return end
    vim.cmd(vim.fn.printf("buffer %d", location.bufnr))
end

---@param bufname string
---@return string
local function format_bufname(bufname)
    local rel = vim.fn.fnamemodify(bufname, ':.')
    if #rel > max_bufname_length then
        return vim.fn.pathshorten(bufname, 3)
    else
        return rel
    end
end

function M.open_window()
    vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern  = { "TelescopePrompt" },
        group    = "ShortContextSwitching",
        once     = true,
        callback = function()
            local bufnr = vim.fn.bufnr()
            local actions = require("telescope.actions")
            vim.keymap.set({ 'n', 'i' }, "<S-Tab>", function() actions.move_selection_worse(bufnr) end,
                { buffer = true, noremap = true })
            vim.keymap.set({ 'n', 'i' }, "<Tab>", function() actions.move_selection_better(bufnr) end,
                { buffer = true, noremap = true })
            vim.keymap.set({ 'n', 'i' }, "<Del>", function()
                    local current_picker = require("telescope.actions.state").get_current_picker(bufnr)
                    current_picker:delete_selection(function(selection)
                        local selected_stack_index = get_index(selection.value.text)
                        if selected_stack_index == #stack then return false end
                        local selected_bufnr = selection.value.text.bufnr
                        local force = vim.api.nvim_buf_get_option(selected_bufnr, "buftype") == "terminal"
                        local ok = pcall(vim.api.nvim_buf_delete, selected_bufnr, { force = force })
                        return ok
                    end)
                end,
                { buffer = true, noremap = true })
        end
    })
    vim.ui.select(stack, {
        prompt = "Switch",
        format_item = function(item) return format_bufname(vim.fn.bufname(item.bufnr)) end
    }, function(item, _)
        if not item then return end
        go_to_location(item)
    end)
end

---@type SCSLocation | nil
local last_valid_location = nil

---@param bufnr integer
---@return SCSLocation | nil
local function stack_has_bufnr(bufnr)
    for _, l in ipairs(stack) do
        if l.bufnr == bufnr then return l end
    end
    return nil
end

---@param location SCSLocation | nil
local function is_valid_location(location)
    if not location then return false end
    local buflisted = vim.fn.getbufvar(location.bufnr, '&buflisted', '')
    if not buflisted then return false end
    local buftype = vim.fn.getbufvar(location.bufnr, '&buftype', '')
    if buftype ~= "" then return false end
    local filetype = vim.fn.getbufvar(location.bufnr, '&filetype', '')
    if filetype == "" or filetype == "Outline" then return false end
    local is_relative = vim.api.nvim_win_get_config(0).relative ~= ''
    return not is_relative
end

---@return SCSLocation
local function get_current_location()
    local winid = vim.fn.win_getid()
    local bufnr = vim.fn.bufnr()
    local line = vim.fn.line(".")
    local column = vim.fn.col(".")

    local existing_location = stack_has_bufnr(bufnr)

    return existing_location or { winid = winid, bufnr = bufnr, line = line, column = column }
end

local function trim_stack()
    stack = vim.fn.filter(stack, function(_, l)
        return vim.api.nvim_buf_is_loaded(l.bufnr) and vim.api.nvim_win_is_valid(l.winid)
    end)
    if #stack > max_stack_size then
        local l = #stack - max_stack_size
        for _ = 1, l, 1 do
            table.remove(stack, #stack)
        end
    end
end

---@return SCSLocation | nil
local function get_top_location()
    return stack[1]
end

---@return SCSLocation | nil
local function get_bottom_location()
    return stack[#stack]
end

---@param location SCSLocation | nil
local function push_location_to_stack(location)
    if not location then return end
    if are_locations_equal(location, get_top_location()) then return end
    local index_of_location = get_index(location)
    if index_of_location ~= -1 then
        table.remove(stack, index_of_location)
    end
    table.insert(stack, 1, location)
    trim_stack()
end

---@param location SCSLocation | nil
local function insert_location_in_stack(location)
    if not location then return end
    if are_locations_equal(location, get_bottom_location()) then return end
    local index_of_location = get_index(location)
    if index_of_location ~= -1 then
        table.remove(stack, index_of_location)
    end
    table.insert(stack, location)
    trim_stack()
end

local function on_win_enter()
    local current = get_current_location()
    if not is_valid_location(current) then return end
    if are_locations_equal(current, last_valid_location) then return end
    push_location_to_stack(last_valid_location)
    insert_location_in_stack(current)
end

local function on_win_leave()
    local current = get_current_location()
    if not is_valid_location(current) then return end
    last_valid_location = current
end

function M.setup()
    vim.api.nvim_create_augroup("ShortContextSwitching", {})
    vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
        pattern = { "*" },
        group = "ShortContextSwitching",
        callback = on_win_enter,
    })
    vim.api.nvim_create_autocmd({ "VimEnter", "WinLeave", "BufLeave" }, {
        pattern = { "*" },
        group = "ShortContextSwitching",
        callback = on_win_leave,
    })

    vim.keymap.set("n", "<S-Tab>", M.open_window, { desc = "Switch context" })
end

return M
