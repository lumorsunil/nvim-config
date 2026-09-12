local telescope = require("telescope")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local sessions = require("init_all.sessions")

local socket_dir = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/nvim-servers"

local function run_session_picker(opts)
  opts = opts or {}

  local project_names = sessions.list()

  pickers
    .new(opts, {
      prompt_title = "Persistent Neovim Sessions",
      finder = finders.new_table({
        results = project_names,
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()

          if selection then
            local project_name = selection[1]
            sessions.switch_to_server(project_name)
          end
        end)
        return true
      end,
    })
    :find()
end

return telescope.register_extension({
  exports = {
    sessions = run_session_picker,
  },
})
