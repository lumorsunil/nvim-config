local M = {}

-- Helper function to return a clean statusline component
function M.statusline_session()
  local server = vim.v.servername

  -- If no server pipe is found at all
  if not server or server == "" then
    return "    Local "
  end

  -- Check if we are using our custom named sockets directory
  if server:match("nvim%-servers") then
    local name = vim.fn.fnamemodify(server, ":t:r")
    -- Returns the capitalized name of your active background project server
    return string.format("    %s ", name)
  end

  -- Fallback for default Neovim random sockets
  return "  Nvim "
end

return M
