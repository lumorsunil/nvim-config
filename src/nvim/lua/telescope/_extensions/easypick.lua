local easypick = require("easypick")
local easypick_pick = require("easypick.pick")
local telescope_config = require("telescope.config")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local pickers = {}

local function url_open_action(prompt_bufnr, _)
    actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        require("url-open.modules.handlers").system_open_url({ open_app = "default" }, selection.match)
    end)
    return true
end

local function ag_entry_maker(entry)
    local path = vim.fn.matchlist(entry, "^\\(.\\{-}\\):")[2]
    local lnum = tonumber(vim.fn.matchlist(entry, ":\\(\\d\\+\\):")[2])
    local match = vim.fn.matchlist(entry, ":\\d\\+:\\(.*\\)")[2]
    return {
        value = entry,
        display = entry,
        ordinal = entry,
        path = path,
        lnum = lnum,
        match = match,
    }
end

return require("telescope").register_extension({
    setup = function()
        table.insert(pickers, {
            name = "urls",
            nargs = 0,
            command = "ag -o \"https?://([^/]+/)+(\\?.*$)?$\"",
            action = url_open_action,
            previewer = telescope_config.values.grep_previewer({}),
            entry_maker = ag_entry_maker,
        })
        table.insert(pickers, {
            name = "ag_ff",
            nargs = 1,
            command = function(opts) return "ag -g " .. opts[1] end,
            previewer = easypick.previewers.default(),
        })
        table.insert(pickers, {
            name = "ag",
            nargs = 1,
            command = function(opts) return "ag " .. opts[1] end,
            previewer = telescope_config.values.grep_previewer({}),
            entry_maker = ag_entry_maker,
        })

        easypick.setup({
            pickers = pickers,
        })
    end,
    exports = {
        urls = function()
            return easypick_pick.one("urls", pickers)
        end,
        ag_ff = function(opts)
---@diagnostic disable-next-line: redundant-parameter
            return easypick_pick.one("ag_ff", pickers, vim.fn.split(opts.command_opts or "", ",", false))
        end,
        ag = function(opts)
---@diagnostic disable-next-line: redundant-parameter
            return easypick_pick.one("ag", pickers, vim.fn.split(opts.command_opts or "", ",", false))
        end,
    },
})
