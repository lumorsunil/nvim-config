local colors_name = 'lushtut'

local colors = {
    -- PATCH_OPEN
Normal = {fg = "#99CFFF", bg = "#031B30"},
DiffText = {link = "Normal"},
SignColumn = {link = "Normal"},
Comment = {fg = "#1B6B8D"},
CursorLine = {bg = "#05335C"},
CursorLineNr = {fg = "#0688F9", italic = true},
DiffAdd = {fg = "#66CC66"},
DiffChange = {fg = "#E5F986"},
DiffDelete = {fg = "#E05252"},
Directory = {fg = "#F7B36E"},
Heading = {fg = "#E5F986"},
["@markup.heading.1.markdown"] = {link = "Heading"},
Heading2 = {fg = "#F7B36E"},
["@markup.heading.2.markdown"] = {link = "Heading2"},
Heading3 = {fg = "#FDF0E2"},
["@markup.heading.3.markdown"] = {link = "Heading3"},
Heading4 = {fg = "#5CB3FF"},
["@markup.heading.4.markdown"] = {link = "Heading4"},
Heading5 = {fg = "#85D685"},
["@markup.heading.5.markdown"] = {link = "Heading5"},
Heading6 = {fg = "#ED9797"},
["@markup.heading.6.markdown"] = {link = "Heading6"},
Identifier = {fg = "#9999FF"},
IncSearch = {fg = "#030302", bg = "#C48945"},
LineNr = {fg = "#1B6B8D", italic = true},
LineNrAbove = {link = "LineNr"},
LineNrBelow = {link = "LineNr"},
NonText = {fg = "#074C88"},
NvimTreeOpenedFile = {fg = "#E5F986", bg = "#05335C"},
Pmenu = {fg = "#99CFFF", bg = "#05335C"},
PreProc = {fg = "#E05252"},
Statement = {fg = "#E5F986"},
Visual = {fg = "#031B30", bg = "#99CFFF"},
["search_base"] = {fg = "#1C1B17", bg = "#C4B345"},
Search = {link = "search_base"},
["@lsp.type.class.markdown"] = {fg = "#267326"},
["@markup.heading.1.marker.markdown"] = {fg = "#E05252"},
["@markup.heading.2.marker.markdown"] = {link = "@markup.heading.1.marker.markdown"},
["@markup.heading.3.marker.markdown"] = {link = "@markup.heading.1.marker.markdown"},
["@markup.heading.4.marker.markdown"] = {link = "@markup.heading.1.marker.markdown"},
["@markup.heading.5.marker.markdown"] = {link = "@markup.heading.1.marker.markdown"},
["@markup.heading.6.marker.markdown"] = {link = "@markup.heading.1.marker.markdown"},
["@markup.list.checked.markdown"] = {fg = "#66CC66"},
["@markup.list.markdown"] = {fg = "#F7B36E"},
["@markup.list.unchecked.markdown"] = {fg = "#E05252"},
["@markup.quote.markdown"] = {fg = "#33A0FF"},
["@punctuation.special.markdown"] = {fg = "#F7B36E"},
    -- PATCH_CLOSE
}

vim.cmd [[highlight clear]]
vim.cmd [[set t_Co=256]]
vim.api.nvim_set_var("colors_name", colors_name)

for group, attrs in pairs(colors) do
    vim.api.nvim_set_hl(0, group, attrs)
end
