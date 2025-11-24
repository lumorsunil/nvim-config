return function()
    local cmp = require("cmp")
    local types = require("cmp.types")
    local lspkind = require("lspkind")

    cmp.setup({
        mapping = require("hook.keybind").hooks.cmp(),
        snippet = {
            expand = function(args)
                vim.fn["vsnip#anonymous"](args.body)
            end
        },
        --- Disabled because of bug in cmp type def
        ---@diagnostic disable-next-line: assign-type-mismatch
        preselect = types.cmp.PreselectMode.None,
        sources = {
            { name = "nvim_lsp" },
            { name = "nvim_lsp_signature_help" },
            { name = "vsnip" },
            { name = "buffer" },
        },
        formatting = {
            expandable_indicator = true,
            format = function(entry, vim_item)
                if vim.tbl_contains({ 'path' }, entry.source.name) then
                    local icon, hl_group = require('nvim-web-devicons').get_icon(entry:get_completion_item().label)
                    if icon then
                        vim_item.kind = icon
                        vim_item.kind_hl_group = hl_group
                        return vim_item
                    end
                end

                vim_item.menu = --[[vim_item.kind .. " " ..--]] entry.source.name ..
                    (vim_item.menu == nil and "" or vim_item.menu)
                vim_item.kind = lspkind.symbolic(vim_item.kind, { mode = "symbol" })

                local maxwidth = 50
                local label = vim_item.abbr
                local truncated_label = vim.fn.strcharpart(label, 0, maxwidth)
                if truncated_label ~= label then
                    vim_item.abbr = truncated_label .. "..."
                end

                return vim_item
            end,
            fields = { "kind", "abbr", "menu" }
        },
    })

    cmp.setup.cmdline('/', {
        mapping = require("hook.keybind").hooks.cmp_cmdline(),
        sources = {
            { name = 'buffer' }
        }
    })

    cmp.setup.cmdline(':', {
        mapping = require("hook.keybind").hooks.cmp_cmdline(),
        sources = cmp.config.sources({
            { name = "path" },
            {
                name = "cmdline",
                option = {
                    ignore_cmds = { 'Man', '!', 'r!' },
                },
            },
        }),
    })

    -- Colors

    vim.api.nvim_set_hl(0, 'CmpItemAbbrDeprecated', { bg = 'NONE', strikethrough = true, fg = '#808080' })
    vim.api.nvim_set_hl(0, 'CmpItemAbbrMatch', { bg = 'NONE', fg = '#569CD6' })
    vim.api.nvim_set_hl(0, 'CmpItemAbbrMatchFuzzy', { link = 'CmpIntemAbbrMatch' })
    vim.api.nvim_set_hl(0, 'CmpItemKindVariable', { bg = 'NONE', fg = '#9CDCFE' })
    vim.api.nvim_set_hl(0, 'CmpItemKindInterface', { link = 'CmpItemKindVariable' })
    vim.api.nvim_set_hl(0, 'CmpItemKindText', { link = 'CmpItemKindVariable' })
    vim.api.nvim_set_hl(0, 'CmpItemKindFunction', { bg = 'NONE', fg = '#C586C0' })
    vim.api.nvim_set_hl(0, 'CmpItemKindMethod', { link = 'CmpItemKindFunction' })
    vim.api.nvim_set_hl(0, 'CmpItemKindKeyword', { bg = 'NONE', fg = '#D4D4D4' })
    vim.api.nvim_set_hl(0, 'CmpItemKindProperty', { link = 'CmpItemKindKeyword' })
    vim.api.nvim_set_hl(0, 'CmpItemKindUnit', { link = 'CmpItemKindKeyword' })
end
