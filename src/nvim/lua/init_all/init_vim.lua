-- @vim

return {
    setup = function()
        vim.opt.termguicolors = true

        -- Hide cursor
        --vim.cmd [[hi Cursor blend=100]]
        --vim.cmd [[set guicursor+=a:Cursor/lCursor]]

        vim.opt.showtabline = 2
        vim.opt.cursorline = true

        --vim.opt.number = true
        --vim.opt.relativenumber = true
        vim.opt.wrap = true
        vim.opt.linebreak = true

        vim.opt.tabstop = 4
        vim.opt.softtabstop = 4
        vim.opt.shiftwidth = 4
        vim.opt.expandtab = true

        vim.opt.completeopt = "menu"

        vim.api.nvim_create_user_command("FormatFile", function()
            local c = vim.fn.col('.')
            local l = vim.fn.line('.')
            local t = vim.fn.line('w0')
            vim.cmd [[normal! gggqG]]

            local shell_error = vim.api.nvim_get_vvar("shell_error")
            if shell_error ~= 0 then
                vim.cmd [[silent undo]]
                vim.cmd [[redraw]]
                --print('Formatprg "' .. vim.bo.formatprg .. '" exited with status ' .. shell_error .. '.')
                vim.cmd("echoerr '" ..
                    'Formatprg "' .. vim.bo.formatprg .. '" exited with status ' .. shell_error .. ".'")
            end

            vim.cmd("" .. t)
            vim.cmd [[normal! zt]]
            vim.fn.cursor({ l, c })
        end, {})

        vim.cmd [[augroup Formatting]]
        vim.cmd [[au!]]
        vim.cmd [[au FileType markdown setlocal formatprg=prettier\ --parser\ markdown formatexpr&]]
        vim.cmd [[au FileType javascript,javascriptreact,typescript,typescriptreact setlocal formatprg=prettier\ --parser\ typescript formatexpr&]]
        vim.cmd [[au FileType css setlocal formatprg=prettier\ --parser\ css formatexpr&]]
        vim.cmd [[au FileType html setlocal formatprg=prettier\ --parser\ html formatexpr&]]
        vim.cmd [[au FileType gohtmltmpl setlocal formatprg=prettier\ --parser\ go-template formatexpr&]]
        vim.cmd [[au FileType json,jsonc setlocal formatprg=prettier\ --parser\ json formatexpr&]]
        vim.cmd [[au BufWritePre *.lua,*.md,*.css,*.html,*.htm,*.json,*.gohtml FormatFile ]]
        vim.cmd [[au BufWritePre *.js,*.jsx,*.ts,*.tsx silent! EslintFixAll ]]
        vim.cmd [[augroup END]]
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = "Formatting",
            pattern = "*.go",
            callback = function()
                local params = vim.lsp.util.make_range_params()
                params.context = { only = { "source.organizeImports" } }
                local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
                for cid, res in pairs(result or {}) do
                    for _, r in pairs(res.result or {}) do
                        if r.edit then
                            local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                            vim.lsp.util.apply_workspace_edit(r.edit, enc)
                        end
                    end
                end
                vim.lsp.buf.format({ async = false })
            end
        })

        vim.filetype.add({
            extension = {
                mylang = "mylang",
                newb = "newb",
                ohm = "ohm"
            }
        })

        vim.opt.tabline = " "

        local function update_tabline(ev)
            if ev.file == "" then
                return
            end
            local icon = require("lspkind").symbol_map.File
            local tabline = "%1T%#TablineIcon# " ..
                icon .. " %#TablineSel#" .. vim.fn.fnamemodify(ev.file, ":~:.") .. " %X"
            vim.opt.tabline = tabline
        end

        vim.api.nvim_create_augroup("TablineCustom", {})
        vim.api.nvim_create_autocmd({ "BufEnter" }, {
            pattern = { "*" },
            group = "TablineCustom",
            callback = update_tabline,
        })

        vim.cmd [[let g:clipboard = {
                \   'name': 'WslClipboard',
                \   'copy': {
                \      '+': 'clip.exe',
                \      '*': 'clip.exe',
                \    },
                \   'paste': {
                \      '+': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
                \      '*': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
                \   },
                \   'cache_enabled': 0,
                \ }]]
    end
}
