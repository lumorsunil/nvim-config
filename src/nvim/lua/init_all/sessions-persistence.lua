-- ==========================================================================
-- PERSISTENT HYBRID SERVER & ROUTER CONFIGURATION WITH CLEANUP
-- ==========================================================================

local sessions = require("init_all.sessions")
local config = sessions.config()
local socket_dir = config.socket_dir
local state_file = config.state_file

local M = {}

function M.setup()
  vim.fn.mkdir(socket_dir, "p")

  -- 1. IDENTIFY THE INSTANCE TYPE
  local is_headless = #vim.api.nvim_list_uis() == 0 or vim.g.is_headless_server

  -- 2. IF RUNNING AS AN INTERACTIVE FRONTEND UI WORKSPACE
  if not is_headless then
    if vim.fn.argc() == 0 and not vim.v.servername:match("nvim%-servers") then
      local f = io.open(state_file, "r")
      if f then
        local last_project = f:read("*l")
        f:close()

        if last_project and last_project ~= "" then
          local target_socket = socket_dir .. "/" .. last_project

          if vim.fn.filereadable(target_socket) == 1 then
            vim.schedule(function()
              vim.cmd("connect " .. target_socket)
              vim.notify("Restored last active session: " .. last_project, vim.log.levels.INFO)
            end)
          end
        end
      end
    end
  end
end

return M
