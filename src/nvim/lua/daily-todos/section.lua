local M = {}

M.Section = {
    MovedFromPrevious = "## Moved from previous",
    New = "## New",
    MovedToNext = "## Moved to next",
}

M.section_order = {
    M.Section.MovedFromPrevious,
    M.Section.New,
    M.Section.MovedToNext,
}

---@param section string
---@return integer
function M.get_section_order_index(section)
    for i, s in ipairs(M.section_order) do
        if s == section then return i end
    end
    return -1
end

---@param section string
---@return string | nil
function M.get_next_section(section)
    local index = M.get_section_order_index(section)
    return M.section_order[index + 1]
end

---@param section string
---@return integer | nil
function M.get_section_line(section)
    local line = vim.fn.search("^" .. section .. "$", "nw")
    if line == 0 then return nil end
    return line
end

---@param section string
---@param start_line? integer
---@return integer | nil
function M.get_section_end_line(section, start_line)
    start_line = start_line or M.get_section_line(section)
    if start_line == nil then return nil end
    vim.fn.cursor({ start_line + 2, 1 })
    local end_line = vim.fn.search("^$", "nW")
    if end_line == 0 then return vim.fn.line('$') end
    return end_line
end

---@param section string
function M.get_next_section_line(section)
    local next_section = M.get_next_section(section)
    if next_section == nil then return nil end
    return M.get_section_line(next_section)
end

---@param section string
---@return integer
function M.get_section_insert_line(section)
    local next_section_line = M.get_next_section_line(section)
    if next_section_line == nil then return vim.fn.line('$') end
    return next_section_line - 1
end

---@param section string
function M.create_section(section)
    local insert_line = M.get_section_insert_line(section)
    vim.cmd("" .. insert_line)
    vim.api.nvim_put({ "", section, "", "" }, "V", false, true)
end

---@param section string
function M.get_section_range(section)
    local start_line = M.get_section_line(section)
    if start_line == nil then return nil end
    local end_line = M.get_section_end_line(section)
    return {
        start_line = start_line,
        end_line = end_line,
        lines = end_line - start_line
    }
end

---@param section string
function M.delete_section(section)
    local range = M.get_section_range(section)
    if range == nil then return end
    vim.fn.cursor({ range.start_line, 1 })
    vim.cmd("silent normal! " .. (range.lines + 1) .. "dd")
end

---@param section string
function M.has_items(section)
    local range = M.get_section_range(section)
    if range == nil then return false end
    local first_item_line = range.start_line + 2
    if vim.fn.getline(first_item_line) == "" then return false end
    return true
end

---@param section string
function M.section_get_items(section)
    local range = M.get_section_range(section)
    if range == nil then return {} end
    local results = {}
    for i = 3, range.lines, 1 do
        results[i - 2] = vim.fn.getline(range.start_line + i - 1)
    end
    return results
end

---@param section string
---@param item string
function M.section_add_item(section, item)
    local add_line = M.get_section_end_line(section)
    if add_line == nil then
        M.create_section(section)
    end
    add_line = M.get_section_end_line(section)
    if M.has_items(section) then
        vim.fn.cursor({ add_line, 1 })
        vim.api.nvim_put({ item }, "V", false, true)
        vim.cmd [[silent normal! k]]
    else
        vim.fn.cursor({ add_line - 1, 1 })
        vim.api.nvim_put({ item }, "c", false, true)
    end
end

---@param section string
---@param line integer
function M.section_remove_item(section, line)
    vim.fn.cursor({ line, 1 })
    vim.cmd [[silent normal! dd]]
    if not M.has_items(section) then
        M.delete_section(section)
    end
end

---@param line integer
---@return string | nil
function M.get_section(line)
    for _, section in ipairs(M.section_order) do
        local range = M.get_section_range(section)
        if range ~= nil and range.start_line <= line and range.end_line >= line then
            return section
        end
    end
    return nil
end

return M
