local lush                = require('lush')

local hsl                 = lush.hsl

local sea_foam            = hsl(208, 100, 80) -- Vim has a mapping, <n>C-a and <n>C-x to
local sea_twilight        = hsl(240, 100, 80)
local sea_crest           = hsl(208, 90, 30)  -- increment or decrement integers, or
local sea_deep            = hsl(208, 90, 10)  -- you can just type them normally.
local sea_coral           = hsl(70, 90, 75)
local sea_shell           = hsl(30, 90, 70)
local sea_crab            = hsl(0, 70, 60)
local sea_grass           = hsl(120, 50, 60)

local sea_gull            = hsl("#c6c6c6")

local sea_foam_triadic    = sea_foam.rotate(120)
local sea_foam_complement = sea_foam.rotate(180).darken(10).saturate(10)

---@diagnostic disable: undefined-global
local theme               = lush(function(injected_functions)
    local sym = injected_functions.sym
    return {
        Normal { bg = sea_deep, fg = sea_foam }, -- Goodbye gray, hello blue!
        Heading { fg = sea_coral },
        Heading2 { fg = sea_shell },
        Heading3 { fg = sea_shell.lighten(80) },
        Heading4 { fg = sea_foam.darken(15) },
        Heading5 { fg = sea_grass.lighten(20) },
        Heading6 { fg = sea_crab.lighten(40) },
        CursorLine { bg = Normal.bg.lighten(10) }, -- lighten() can also be called via li()
        Visual { fg = Normal.bg, bg = Normal.fg }, -- Try pressing v and selecting some text
        Comment { fg = Normal.bg.de(25).li(25).ro(-10) },
        LineNr { Comment, gui = "italic" },
        LineNrBelow { LineNr },
        LineNrAbove { LineNr },
        CursorLineNr { LineNr, fg = CursorLine.bg.mix(Normal.fg, 50) },
        search_base { bg = hsl(52, 52, 52), fg = hsl(52, 10, 10) },
        Search { search_base },
        IncSearch { bg = search_base.bg.ro(-20), fg = search_base.fg.da(90) },
        Pmenu { bg = CursorLine.bg, fg = Normal.fg },

        sym "@markup.heading.1.markdown" { Heading },
        sym "@markup.heading.2.markdown" { Heading2 },
        sym "@markup.heading.3.markdown" { Heading3 },
        sym "@markup.heading.4.markdown" { Heading4 },
        sym "@markup.heading.5.markdown" { Heading5 },
        sym "@markup.heading.6.markdown" { Heading6 },
        sym "@markup.heading.1.marker.markdown" { fg = sea_crab },
        sym "@markup.heading.2.marker.markdown" { sym "@markup.heading.1.marker.markdown" },
        sym "@markup.heading.3.marker.markdown" { sym "@markup.heading.1.marker.markdown" },
        sym "@markup.heading.4.marker.markdown" { sym "@markup.heading.1.marker.markdown" },
        sym "@markup.heading.5.marker.markdown" { sym "@markup.heading.1.marker.markdown" },
        sym "@markup.heading.6.marker.markdown" { sym "@markup.heading.1.marker.markdown" },
        sym "@punctuation.special.markdown" { fg = sea_shell },
        sym "@markup.list.markdown" { fg = sea_shell },
        sym "@markup.list.checked.markdown" { fg = sea_grass },
        sym "@markup.list.unchecked.markdown" { fg = sea_crab },
        sym "@markup.quote.markdown" { fg = Normal.fg.darken(25) },
        sym "@lsp.type.class.markdown" { fg = sea_grass.darken(50) },

        DiffAdd { fg = sea_grass },
        DiffDelete { fg = sea_crab },
        DiffText { Normal },
        DiffChange { fg = sea_coral },
        SignColumn { Normal },
        NonText { fg = sea_deep.lighten(20) },

        PreProc { fg = sea_crab },
        Directory { fg = sea_shell },
        Statement { fg = sea_coral },
        Identifier { fg = sea_twilight },

        NvimTreeOpenedFile { fg = Statement.fg, bg = CursorLine.bg },
    }
end)

return theme
