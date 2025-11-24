local lush                = require('lush')
local hsl                 = lush.hsl

local normalbg = hsl(60, 40, 5)
local normalfg = hsl(60, 40, 50)

local ok = hsl(120, 70, 60)
local error = hsl(0, 70, 60)
local warning = hsl(60, 80, 60)

---@diagnostic disable: undefined-global
local theme = lush(function(injected_functions)
    local sym = injected_functions.sym
    return {
        Normal { bg = normalbg, fg = normalfg },
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
        Search { bg = Normal.fg, fg = Normal.bg },
        IncSearch { bg = Search.bg.ro(-20), fg = Search.fg.da(90) },
        Pmenu { bg = CursorLine.bg, fg = Normal.fg },

        DiffAdd { fg = ok },
        DiffDelete { fg = error },
        DiffText { Normal },
        DiffChange { fg = warning },
        SignColumn { Normal },
        NonText { fg = Normal.bg.lighten(5) },

        NvimTreeOpenedFile { fg = Statement.fg, bg = CursorLine.bg },

        PreProc { fg = error },
        Directory { fg = normalfg.ro(-30).sa(10) },
        --Statement { fg = flimmer_cyan },
        Identifier { fg = normalfg },
        Special { fg = normalfg.de(80).da(40) },
        Constant { fg = normalfg.sa(80).da(30).ro(90) },

        sym "@number.json" { fg = Constant.fg.ro(120).de(30).li(50) },

        Error { fg = error },
        ErrorMsg { Error },
        DiagnosticError { Error },
        WarningMsg { fg = warning },
    }
end)

return theme
