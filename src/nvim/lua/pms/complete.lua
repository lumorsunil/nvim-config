local M = {}

---@param get_labels fun(): string[]
function M.mk_complete_fn(get_labels)
    return function(_, line, _)
        local l = vim.split(line, "%s+")
        return vim.tbl_filter(function(val)
            return vim.startswith(val, l[2])
        end, get_labels())
    end
end

return M
