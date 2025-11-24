---@class PluginConfigs
local M = {}

M.tree = function() return require("plugins-configs.configs.init_tree")() end
M.lsp = function() return require("plugins-configs.configs.init_lsp")() end
M.telescope = function() return require("plugins-configs.configs.init_telescope")() end
M.dap = function() return require("plugins-configs.configs.init_dap")() end
M.rest = function() return require("plugins-configs.configs.init_rest")() end
M.cmp = function() return require("plugins-configs.configs.init_cmp")() end
M.bufferline = function() return require("plugins-configs.configs.init_bufferline")() end
M.gitsigns = function() return require("plugins-configs.configs.init_gitsigns")() end
M.lualine = function() return require("plugins-configs.configs.init_lualine")() end
M.treesitter = function() return require("plugins-configs.configs.init_treesitter")() end
M.rainbow = function() return require("plugins-configs.configs.init_rainbow")() end
M.terminal = function() return require("plugins-configs.configs.init_terminal")() end
M.cloak = function() return require("plugins-configs.configs.init_cloak")() end
M.colorizer = function() return require("plugins-configs.configs.init_colorizer")() end
M.twilight = function() return require("plugins-configs.configs.init_twilight")() end
M.urlopen = function() return require("plugins-configs.configs.init_url_open")() end
M.illuminate = function() return require("plugins-configs.configs.init_illuminate")() end
M.outline = function() return require("plugins-configs.configs.init_outline")() end
M.overseer = function() return require("plugins-configs.configs.init_overseer")() end

return M
