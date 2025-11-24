local fs = require "fs"
local M = {}

M.auto_task_handlers = {}

---@param handler fun(date: string): string[]
function M.register_auto_task_handler(handler)
    table.insert(M.auto_task_handlers, handler)
end

---@param date string
local function generate_auto_tasks(date)
    ---@type string[]
    local auto_tasks = {}
    for _, handler in ipairs(M.auto_task_handlers) do
        for _, task in ipairs(handler(date)) do
            table.insert(auto_tasks, task)
        end
    end
    return auto_tasks
end

function M.get_root_path()
    return vim.fn.environ().HOME .. "/daily-todo"
end

---@param date string
---@return string
function M.get_entry_path(date)
    return M.get_root_path() .. "/daily-todo-" .. date .. ".md"
end

---@return string
function M.get_autoselect_date()
    local fname = vim.fn.expand('%')
    local date_in_fname = vim.fn.matchstr(fname, [[\d\{4}-\d\{2}-\d\{2}]])
    if date_in_fname == "" then return M.get_todays_date() end
    return date_in_fname
end

---@return string[]
function M.get_existing_entries()
    local root_path = M.get_root_path()
    local entries = vim.fn.glob(root_path .. "/daily-todo-*.md", false, true)
    return entries
end

---@param entries? string[]
---@return integer
function M.find_current_entry_index(entries)
    entries = entries or M.get_existing_entries()
    local current = vim.fn.expand("%:p")
    local index = -1

    for i, entry in ipairs(entries) do
        if current == entry then
            index = i
            break
        end
    end

    return index
end

---@param cycle? boolean
---@return string | nil
function M.find_next_existing_entry(cycle)
    local entries = M.get_existing_entries()
    local index = M.find_current_entry_index(entries)

    if index == -1 then return nil end
    local next_index

    if cycle then
        next_index = (index % #entries) + 1
    else
        next_index = (index + 1)
    end

    return entries[next_index]
end

---@param cycle? boolean
---@return string | nil
function M.find_previous_existing_entry(cycle)
    local entries = M.get_existing_entries()
    local index = M.find_current_entry_index(entries)

    if index == -1 then return nil end
    local next_index

    if cycle then
        next_index = (index - 1) % #entries
        if next_index < 1 then next_index = #entries end
    else
        next_index = (index - 1)
    end

    return entries[next_index]
end

---@param file_path string
---@param error_if_false? boolean
---@return { exists: boolean, accessable: boolean }
local function is_not_dir_and_writable(file_path, error_if_false)
    local writable = vim.fn.filewritable(file_path)
    if writable == 2 then
        if error_if_false then error("Cannot open " .. file_path .. " is a directory.") end
        return { exists = true, accessable = false }
    end
    local exists = fs.file_exists(file_path)
    if exists and writable == 0 then
        if error_if_false then error("Cannot write to " .. file_path) end
        return { exists = true, accessable = false }
    end
    return { exists = exists, accessable = true }
end

---@return string
function M.get_todays_date()
    return vim.fn.strftime("%Y-%m-%d")
end

---@param entry string
---@param open_in_tab? boolean
function M.open_daily_todo(entry, open_in_tab)
    if vim.fn.expand('%') ~= entry then
        is_not_dir_and_writable(entry, true)
        if open_in_tab then
            vim.cmd.tabnew()
        end
        vim.cmd.edit(entry)
    end

    local is_empty = vim.fn.line('$') == 1 and vim.fn.getline(1) == ''

    if is_empty then
        -- initialize with template
        local date = vim.fn.matchlist(entry, "\\d\\{4}-\\d\\{2}-\\d\\{2}")[1]
        vim.api.nvim_put({
            "# daily-todo " .. date,
            "",
            "## New",
            "",
        }, "V", false, true)
        local auto_tasks = generate_auto_tasks(date)
        for _, task in ipairs(auto_tasks) do
            vim.api.nvim_put({ "- [ ] " .. task }, "V", false, true)
        end
        vim.api.nvim_put({ "- [ ] " }, "c", false, true)
    end
end

return M
