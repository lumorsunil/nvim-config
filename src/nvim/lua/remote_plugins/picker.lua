local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local finder = require("remote_plugins.finder")
local previewer = require("remote_plugins.previewer")

local function create_picker(opts)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "remote_plugins",
        finder = finders.new_dynamic({
            fn = finder.generate_results,
            ---@param entry { rank: number, plugin: { createdAt: string, updatedAt: string, watcher: number, description: string, branch: string, username: string, repo: string, name: string, homepage: string, openIssues: number, forks: number, link: string, stars: number, tags: table, subscribers: number, id: string, network: number } }
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry.plugin.name,
                    ordinal = entry.plugin.name,
                }
            end,
        }),
        sorter = conf.generic_sorter(opts),
        previewer = previewer,
        attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                require("url-open.modules.handlers").system_open_url({ open_app = "default" }, selection.value.plugin.link)
            end)
            return true
        end,
    }):find()
end

M.picker = create_picker

function M.setup()
end

return M
