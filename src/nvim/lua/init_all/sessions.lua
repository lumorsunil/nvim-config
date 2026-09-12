-- //////////////////////////////////////// --
-- ///                                  /// --
-- ///     NVIM REMOTE MULTIPLEXER      /// --
-- ///                                  /// --
-- //////////////////////////////////////// --

local M = {}

local socket_dir = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/nvim-servers"
local state_file = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")) .. "/nvim-last-session.txt"

function M.config()
  return {
    socket_dir = socket_dir,
    state_file = state_file,
  }
end

-- Helper function to save the last session name
local function save_last_session(name)
  local f = io.open(state_file, "w")
  if f then
    f:write(name)
    f:close()
  end
end

-- Remap :q etc to not quit the server instance
local function setup_keybindings()
  -- vim.notify_once("session keybindings setup")
  if #vim.api.nvim_list_uis() == 0 or vim.g.is_headless_server then
    -- Define the smart quit function
    _G.smart_quit_or_detach = function()
      local win_count = #vim.api.nvim_list_wins()
      local tab_count = #vim.api.nvim_list_tabpages()

      -- If it's the last window in the last tab, detach safely to leave server alive
      if win_count == 1 and tab_count == 1 then
        vim.cmd("detach")
      else
        -- Otherwise, just close the active window/split normally
        -- vim.cmd("close")
        vim.cmd("close")
      end
    end

    -- Create a custom uppercase command as a fallback execution engine
    vim.api.nvim_create_user_command("SmartQuit", function()
      _G.smart_quit_or_detach()
    end, {})

    -- A helper function to safely map lowercase command abbreviations
    local function cabbrev(lhs, rhs)
      vim.cmd(
        string.format(
          "cnoreabbrev <expr> %s (getcmdtype() == ':' && getcmdline() == '%s') ? '%s' : '%s'",
          lhs,
          lhs,
          rhs,
          lhs
        )
      )
    end

    -- Safely intercept quit commands and swap them to detach
    cabbrev("q", "SmartQuit")
    cabbrev("qa", "detach")
    cabbrev("wq", "w \\| SmartQuit")
    cabbrev("wqa", "wa \\| detach")

    require("hook.keybind").hooks.sessions()
  end
end

local function setup_commands()
  -- Command autocomplete helper
  vim.api.nvim_create_user_command("Session", function(opts)
    M.switch_to_server(opts.args)
  end, {
    nargs = 1,
    complete = M.list,
  })
end

-- Function to hot-swap the entire Neovim UI engine to another server
function M.switch_to_server(project_name)
  local socket_path = socket_dir .. "/" .. project_name

  save_last_session(project_name)

  if vim.fn.filereadable(socket_path) == 0 then
    vim.notify("No running server found for project: " .. project_name, vim.log.levels.ERROR)
    return
  end

  -- Tell the active client to seamlessly drop the current server
  -- and reattach its UI to the new project socket
  vim.cmd("connect " .. socket_path)
end

function M.list()
  local files = vim.fn.glob(socket_dir .. "/*", false, true)
  local names = {}
  for _, file in ipairs(files) do
    table.insert(names, vim.fn.fnamemodify(file, ":t:r"))
  end
  return names
end

function M.current(sessions)
  sessions = sessions or M.list()
  local current = vim.fs.basename(vim.v.servername)

  if current == nil then
    return nil
  end

  for index, value in ipairs(sessions) do
    if value == current then
      return { session = value, index = index }
    end
  end

  return nil
end

function M.state()
  local sessions = M.list()
  local current = M.current(sessions)

  return { sessions = sessions, current = current }
end

function M.setup()
  setup_keybindings()
  setup_commands()
  require("init_all.sessions-persistence").setup()
end

return M
