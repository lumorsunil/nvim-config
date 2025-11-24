local M = {}

---@param file_path string
---@return boolean
function M.file_exists(file_path)
    return #vim.fn.glob(file_path) > 0
end

return M
