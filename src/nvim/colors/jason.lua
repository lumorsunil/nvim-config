local colors_name = 'jason'

local colors = {
    -- PATCH_OPEN
Normal = {fg = "#B2B34D", bg = "#121208"},
DiffText = {link = "Normal"},
SignColumn = {link = "Normal"},
Comment = {fg = "#606034"},
Constant = {fg = "#0BA859"},
CursorLine = {bg = "#363617"},
DiffAdd = {fg = "#52E052"},
DiffChange = {fg = "#EBEB47"},
DiffDelete = {fg = "#E05252"},
Directory = {fg = "#BA8045"},
Error = {fg = "#E05252"},
DiagnosticError = {link = "Error"},
ErrorMsg = {link = "Error"},
Identifier = {fg = "#B2B34D"},
IncSearch = {fg = "#040402", bg = "#B3914D"},
LineNr = {fg = "#606034", italic = true},
NonText = {fg = "#24240F"},
NvimTreeOpenedFile = {bg = "#363617"},
Pmenu = {fg = "#B2B34D", bg = "#363617"},
PreProc = {fg = "#E05252"},
Search = {fg = "#121208", bg = "#B2B34D"},
Special = {fg = "#535346"},
Visual = {fg = "#121208", bg = "#B2B34D"},
WarningMsg = {fg = "#EBEB47"},
["@number.json"] = {fg = "#AD7BE0"},
    -- PATCH_CLOSE
}

vim.cmd [[highlight clear]]
vim.cmd [[set t_Co=256]]
vim.api.nvim_set_var("colors_name", colors_name)

for group, attrs in pairs(colors) do
    vim.api.nvim_set_hl(0, group, attrs)
end
