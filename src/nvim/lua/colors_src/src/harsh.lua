local lush                = require('lush')
local hsl                 = lush.hsl

local flimmer_green       = hsl(120, 40, 60)
local flimmer_yellow      = flimmer_green.rotate(300).de(-50)
local flimmer_red         = flimmer_yellow.rotate(300)
local flimmer_red_dim     = flimmer_red.de(50).da(20)
local flimmer_blue        = flimmer_red.rotate(210).sa(50)
local flimmer_cyan        = hsl(180, 60, 65)
local flimmer_void        = hsl(140, 60, 4)

---@diagnostic disable: undefined-global
local theme = lush(function(injected_functions)
    local sym = injected_functions.sym
    return {
        Normal { bg = flimmer_void, fg = flimmer_green },
        --Heading { fg = sea_coral },
        --Heading2 { fg = sea_shell },
        --Heading3 { fg = sea_shell.lighten(80) },
        --Heading4 { fg = sea_foam.darken(15) },
        --Heading5 { fg = sea_grass.lighten(20) },
        --Heading6 { fg = sea_crab.lighten(40) },
        CursorLine { bg = Normal.bg.lighten(10) },
        Visual { fg = Normal.bg, bg = Normal.fg },
        Comment { fg = Normal.bg.de(25).li(25) },
        LineNr { Comment, gui = "italic" },
        --CursorLineNr { LineNr, fg = CursorLine.bg.mix(Normal.fg, 50) },
        --search_base { bg = hsl(52, 52, 52), fg = hsl(52, 10, 10) },
        Search { bg = flimmer_yellow, fg = Normal.bg },
        IncSearch { bg = Search.bg.ro(-20), fg = Search.fg.da(90) },
        Pmenu { bg = CursorLine.bg, fg = Normal.fg },

        DiffAdd { fg = flimmer_green.saturate(100) },
        DiffDelete { fg = flimmer_red },
        DiffText { Normal },
        DiffChange { fg = flimmer_yellow },
        SignColumn { Normal },
        NonText { fg = Normal.bg.lighten(5) },

        NvimTreeOpenedFile { fg = Statement.fg, bg = CursorLine.bg },

        sym "@string.bash" { fg = flimmer_red_dim },
        sym "@keyword.directive.bash" { fg = flimmer_blue },

        PreProc { fg = flimmer_red_dim },
        Directory { fg = flimmer_blue },
        Statement { fg = flimmer_cyan },
        Identifier { fg = flimmer_green },
        Special { fg = flimmer_blue.de(30).da(30) },
        Constant { fg = flimmer_red_dim },

        Error { fg = flimmer_red },
        ErrorMsg { Error },
        DiagnosticError { Error },
        WarningMsg { fg = flimmer_yellow },
    }
end)

return theme
