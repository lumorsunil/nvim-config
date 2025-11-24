local M = {}

local require_errors = {}

function M.try(fn, args)
    local r, err = pcall(fn, args)
    if not err then return r end
    print(err)
    return nil
end

function M.try_require(s)
    local ok, res = pcall(require, s)
    if not ok then
        table.insert(require_errors, res)
    end
    return ok, res
end

---@param m { setup: fun() }
function M.try_setup(m)
    local ok, res = pcall(m.setup)
    if not ok and res then
        table.insert(require_errors, res)
    end
    return res
end

function M.has_errors()
    return #require_errors > 0
end

function M.show_errors(errors)
    errors = errors or require_errors
    vim.cmd [[silent! exe 'noautocmd botright pedit init_all_errors']]
    vim.cmd [[noautocmd wincmd P]]
    vim.cmd [[set buftype=nofile]]
    for k, err in ipairs(require_errors) do
        local lines = {}
        for s in err:gmatch("[^\r\n]+") do
            table.insert(lines, s)
        end
        vim.api.nvim_put(lines, "l", false, true)
    end
    vim.cmd [[noautocmd wincmd p]]
end

return M
