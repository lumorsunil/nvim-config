local M = {}

function M.setup()
    local group = vim.api.nvim_create_augroup("Mylang", {})
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        group = group,
        pattern = { "*.mylang" },
        callback = function()
            vim.cmd.setfiletype("mylang")
        end
    })
    vim.api.nvim_create_autocmd("Syntax", {
        group = group,
        pattern = { "mylang" },
        callback = function()
            vim.cmd [[runtime! syntax/mylang.vim]]
        end
    })
end

return M
