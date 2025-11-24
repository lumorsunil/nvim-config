local keybinds = require("hook.keybind").hooks

local M = {}

local twitchBuffer = 0

local function assertTwitchBufferInitialized()
    assert(twitchBuffer > 0, "twitch buffer not set")
end

--- @param tabnr integer
--- @return integer|nil
local function findBufferWindow(tabnr)
    assertTwitchBufferInitialized()
    local windows = vim.api.nvim_tabpage_list_wins(tabnr)
    for _, window in ipairs(windows) do
        local buffer = vim.api.nvim_win_get_buf(window)
        if buffer == twitchBuffer then return window end
    end
    return nil
end

--- @return integer|nil
local function findShownBufferWindow()
    return findBufferWindow(0)
end

--- @return boolean
local function isBufferWindowShown()
    return findBufferWindow(0) ~= nil
end

local function createBufferWindow()
    assertTwitchBufferInitialized()
    local window = vim.api.nvim_get_current_win()
    local twitchWindow = vim.api.nvim_open_win(twitchBuffer, false,
        {
            title = "Chat",
            border = "double",
            relative = "editor",
            width = 30,
            height = vim.o.lines - 3,
            anchor = "NE",
            row = 0,
            col = vim.o.columns - 1,
            noautocmd = true
        })
    vim.api.nvim_win_set_buf(twitchWindow, twitchBuffer)
    vim.api.nvim_create_autocmd("TabLeave", {
        once = true,
        callback = function()
            local prevTwitchWindow = findShownBufferWindow()
            if prevTwitchWindow == nil then return end
            vim.api.nvim_win_close(prevTwitchWindow, true)
            vim.api.nvim_create_autocmd("TabEnter", {
                once = true,
                callback = function() createBufferWindow() end
            })
        end
    })
    vim.api.nvim_set_current_win(window)
    return twitchWindow
end

local function checkIfBufferExists()
    return twitchBuffer ~= 0 and vim.fn.bufexists(twitchBuffer)
end

local function initBuffer()
    if checkIfBufferExists() then return end
    twitchBuffer = vim.api.nvim_create_buf(false, false)
    local twitchWindow = createBufferWindow()
    local window = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(twitchWindow)
    vim.cmd.terminal("bork start")
    vim.api.nvim_create_autocmd("TermClose", {
        buffer = twitchBuffer,
        once = true,
        callback = function() vim.cmd [[!bork quit]] end
    })
    vim.api.nvim_set_current_win(window)
end

local function showBuffer()
    assertTwitchBufferInitialized()
    if isBufferWindowShown() then return end
    createBufferWindow()
end

local function hideBuffer()
    if twitchBuffer == 0 then return end
    local window = findShownBufferWindow()
    if window then vim.api.nvim_win_hide(window) end
end

function M.setup()
    vim.api.nvim_create_user_command("TwitchChatShow", function()
        initBuffer()
        showBuffer()
    end, {})

    vim.api.nvim_create_user_command("TwitchChatHide", function()
        hideBuffer()
    end, {})

    vim.api.nvim_create_user_command("TwitchChatToggle", function()
        if checkIfBufferExists() and isBufferWindowShown() then
            hideBuffer()
        else
            initBuffer()
            showBuffer()
        end
    end, {})

    keybinds.twitch()
end

return M
