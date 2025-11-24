local colors_name = 'harsh'

local colors = {
    -- PATCH_OPEN
Normal = {fg = "#70C270", bg = "#041008"},
DiffText = {link = "Normal"},
SignColumn = {link = "Normal"},
Comment = {fg = "#27683D"},
Constant = {fg = "#A55050"},
CursorLine = {bg = "#0E391D"},
DiffAdd = {fg = "#33FF33"},
DiffChange = {fg = "#E0E052"},
DiffDelete = {fg = "#E05252"},
Directory = {fg = "#4299F0"},
Error = {fg = "#E05252"},
DiagnosticError = {link = "Error"},
ErrorMsg = {link = "Error"},
Identifier = {fg = "#70C270"},
IncSearch = {fg = "#000000", bg = "#E0B152"},
LineNr = {fg = "#27683D", italic = true},
NonText = {fg = "#092512"},
Pmenu = {fg = "#70C270", bg = "#0E391D"},
PreProc = {fg = "#A55050"},
Search = {fg = "#041008", bg = "#E0E052"},
Special = {fg = "#2B6BAB"},
Statement = {fg = "#70DBDB"},
Visual = {fg = "#041008", bg = "#70C270"},
WarningMsg = {fg = "#E0E052"},
["@keyword.directive.bash"] = {fg = "#4299F0"},
["@string.bash"] = {fg = "#A55050"},
    -- PATCH_CLOSE
}

vim.cmd [[highlight clear]]
vim.cmd [[set t_Co=256]]
vim.api.nvim_set_var("colors_name", colors_name)

for group, attrs in pairs(colors) do
    vim.api.nvim_set_hl(0, group, attrs)
end
