return function()
    ---@param source string
    ---@param target string
    ---@diagnostic disable-next-line: unused-function
    local function inverthl(source, target)
        local bg = vim.fn.synIDattr(vim.fn.hlID(source), "bg#")
        --local hl = vim.api.nvim_get_hl(vim.fn.hlID("gitsigns"), { name = name, link = false })
        print("setting " .. target .. " guifg=" .. bg)
        vim.cmd("highlight " .. target .. " guibg=NONE")
        vim.cmd("highlight " .. target .. " guifg=" .. bg)
    end

    -- Needed when colorscheme was set to desert
    ---@diagnostic disable-next-line: unused-function, unused-local
    local function invert_gitsigns_highlights()
        inverthl("DiffAdd", "GitSignsAdd")
        inverthl("DiffDelete", "GitSignsDelete")
        inverthl("DiffChange", "GitSignsChange")
    end

    require("gitsigns").setup({
        on_attach = function(_)
            -- invert_gitsigns_highlights()
        end,
    })
end
