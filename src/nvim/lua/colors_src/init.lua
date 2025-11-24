local M = {}

local default_theme = "tokyonight-night"

local is_enabled = true

local current_themes = {}

local function set_current_theme(win, theme)
    current_themes[win] = theme
end

local function get_current_theme(win)
    return current_themes[win]
end

---@type table<string, string>
local ft_themes = {
    ["lua"] = "tokyonight-night",
    ["go"] = "tokyonight-night",
    ["gomod"] = "tokyonight-night",
    ["javascript"] = "vscode",
    ["javascriptreact"] = "vscode",
    ["typescript"] = "vscode",
    ["typescriptreact"] = "vscode",
    ["html"] = "vscode",
    ["gohtmltmpl"] = "vscode",
    ["css"] = "vscode",
    ["json"] = "jason",
    ["jsonc"] = "jason",
    ["markdown"] = "lushtut",
    ["DiffviewFiles"] = "tokyonight-night",
    ["sh"] = "harsh",
    ["bash"] = "harsh",
    ["zig"] = "melange",
    ["rust"] = "melange",
}

---@param theme string
local function get_ns(theme)
    local ns_name = "colorsrc_" .. theme
    local initialized = vim.api.nvim_get_namespaces()[ns_name]
    local ns = vim.api.nvim_create_namespace(ns_name)
    return ns, initialized
end

local function apply_tab_styles()
    vim.api.nvim_set_hl(0, "TabLine", { link = "Normal" })
    vim.api.nvim_set_hl(0, "TabLineIcon", { link = "NvimTreeOpenedFile" })
    vim.api.nvim_set_hl(0, "TabLineFill", { link = "Normal" })
    vim.api.nvim_set_hl(0, "TabLineSel", { link = "CursorLine" })
end

---@param theme string
---@param global? boolean
local function apply_theme(theme, global)
    if global then
        vim.cmd.colorscheme(theme)
        apply_tab_styles()
        return
    end

    local ns, initialized = get_ns(theme)
    vim.api.nvim_win_set_hl_ns(0, ns)

    if not initialized then
        local set_hl = vim.api.nvim_set_hl
        ---@diagnostic disable-next-line: duplicate-set-field
        vim.api.nvim_set_hl = function(_, group, hl)
            set_hl(ns, group, hl)
        end
        vim.cmd.colorscheme(theme)
        apply_tab_styles()
        vim.api.nvim_set_hl = set_hl
    end

    vim.g.colors_name = nil
end

---@param theme string
local function draw_theme(theme)
    apply_theme(theme)
    apply_theme(default_theme, true)
end

---@param filetype string
local function switch(filetype)
    local theme = ft_themes[filetype] or default_theme
    if theme == "*" then return end
    local win = vim.api.nvim_get_current_win()
    local current_theme = get_current_theme(win)
    if theme == current_theme then return end
    set_current_theme(win, theme)
    draw_theme(theme)
end

function M.disable()
    is_enabled = false
end

function M.enable()
    is_enabled = true
end

-- TODO: implement this, currently crashing when called
function M.split_colorscheme()
    local current_theme = get_current_theme(vim.api.nvim_get_current_win())
    local colorscheme_path = vim.fn.stdpath("config") .. "/lua/colors_src/src/" .. current_theme .. ".lua"
    vim.cmd([[belowright new ]] .. colorscheme_path)
end

function M.edit_current_colorscheme()
    M.disable()
    M.split_colorscheme()
    vim.cmd [[Lushify]]
end

function M.print_info()
    print(vim.inspect({
        current_theme = get_current_theme(vim.api.nvim_get_current_win())
    }))
end

function M.redraw()
    local current_theme = get_current_theme(vim.api.nvim_get_current_win())
    draw_theme(current_theme)
end

function M.apply_global_theme()
    apply_theme(default_theme, true)
end

function M.setup()
    M.enable()

    M.apply_global_theme()

    vim.api.nvim_create_user_command("ColorSrcEdit", M.edit_current_colorscheme, {})
    vim.api.nvim_create_user_command("ColorSrcOpen", M.split_colorscheme, {})
    vim.api.nvim_create_user_command("ColorSrcInfo", M.print_info, {})
    vim.api.nvim_create_user_command("ColorSrcRedraw", M.redraw, {})

    local group = vim.api.nvim_create_augroup("FileTypeColorSchemes", {})
    vim.api.nvim_create_autocmd({ "FileType", "WinEnter", "BufEnter", "VimEnter" }, {
        pattern = { "*" },
        group = group,
        callback = function()
            if not is_enabled then return end
            switch(vim.bo.filetype)
        end,
    })
end

return M
