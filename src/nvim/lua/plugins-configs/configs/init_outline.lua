local is_debug = false

local function debug_log(...)
    if is_debug then print(...) end
end

local function is_enabled()
    return vim.api.nvim_get_var("outline_enabled")
end

---@param filetype string
local function current_tab_has_filetype(filetype)
    local tabinfo = vim.fn.gettabinfo(vim.fn.tabpagenr())[1]
    for _, win in ipairs(tabinfo.windows) do
        local buf = vim.fn.getwininfo(win)[1].bufnr
        local ft = vim.fn.getbufvar(buf, "&filetype")
        if ft == filetype then return true end
    end
    return false
end

local function is_in_diffview()
    return current_tab_has_filetype("DiffviewFiles")
end

local function is_attachable()
    if not vim.bo.buflisted then return false end
    if is_in_diffview() then return false end
    if vim.bo.filetype == "" or vim.bo.filetype == "Outline" then return false end
    return is_enabled()
end

local function is_ready_to_attach()
    return is_attachable() and not require("outline").is_open()
end

local function attach_outline()
    vim.cmd [[OutlineOpen!]]
    vim.cmd [[OutlineFollow!]]
end

local function has_attached_to_current()
    local tab = vim.fn.tabpagenr()
    local win = vim.fn.win_getid()
    local buf = vim.fn.bufnr()
    local sb = require("outline").sidebars[tab]
    return sb and win == sb.code.win and buf == sb.code.buf
end

local function s_d()
    return vim.fn.expand('<amatch>') .. " " .. vim.bo.filetype .. " attachable:" .. tostring(is_attachable())
end

local function on_enter()
    debug_log("FTLSP:" .. s_d())
    if is_ready_to_attach() then
        attach_outline()
    end
end

local function on_close()
    debug_log("CLOSE:" .. s_d())
    if vim.bo.filetype == "Outline" then
        vim.api.nvim_set_var("outline_enabled", false)
        return
    end
    if not is_enabled() then return end
    if not has_attached_to_current() then return end
    require("outline").close()
end

local function refresh()
    debug_log("REFRESH:" .. s_d())
    require("outline").refresh()
end

local function try(f)
    return function()
        local ok, err = pcall(f)
        if not ok then
            print("outline error:")
            print(vim.inspect(err))
        end
    end
end

return function()
    vim.api.nvim_set_var("outline_enabled", true)
    require("outline").setup({})

    vim.api.nvim_create_augroup("OutlineManager", {})
    vim.api.nvim_create_autocmd({ "FileType", "LspAttach", "BufEnter" }, {
        pattern = { "*" },
        group = "OutlineManager",
        callback = try(on_enter),
    })
    vim.api.nvim_create_autocmd({ "QuitPre" }, {
        pattern = { "*" },
        group = "OutlineManager",
        callback = try(on_close),
    })
    vim.api.nvim_create_autocmd({ "LspAttach" }, {
        pattern = { "*" },
        group = "OutlineManager",
        callback = try(refresh),
    })

    -- Initial open if attachable
    if is_ready_to_attach() then attach_outline() end
end
