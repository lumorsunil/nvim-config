return function()
  local keybinds = require("hook.keybind").hooks
  -- table.insert(vim.g.markdown_fenced_languages or {}, "runic")
  -- table.insert(vim.g.markdown_fenced_languages or {}, "zig")
  vim.treesitter.language.register("c3", { "c3" })
  vim.treesitter.language.register("nix", "devenv-nix")

  require("nvim-treesitter-textobjects").setup({
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      -- You can choose the select mode (default is charwise 'v')
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * method: eg 'v' or 'o'
      -- and should return the mode ('v', 'V', or '<c-v>') or a table
      -- mapping query_strings to modes.
      selection_modes = {
        ["@parameter.outer"] = "v", -- charwise
        ["@function.outer"] = "V", -- linewise
        ["@class.outer"] = "<c-v>", -- blockwise
      },
      -- If you set this to `true` (default is `false`) then any textobject is
      -- extended to include preceding or succeeding whitespace. Succeeding
      -- whitespace has priority in order to act similarly to eg the built-in
      -- `ap`.
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * selection_mode: eg 'v'
      -- and should return true of false
      include_surrounding_whitespace = true,
    },
    -- swap = {
    --   enable = true,
    --   swap_next = textobjectsmaps.swap.swap_next,
    --   swap_previous = textobjectsmaps.swap.swap_previous,
    -- },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      -- goto_next_start = textobjectsmaps.move.goto_next_start,
      -- goto_next_end = textobjectsmaps.move.goto_next_end,
      -- goto_previous_start = textobjectsmaps.move.goto_previous_start,
      -- goto_previous_end = textobjectsmaps.move.goto_previous_end,
      -- goto_next = textobjectsmaps.move.goto_next,
      -- goto_previous = textobjectsmaps.move.goto_previous,
    },
  })

  keybinds.treesitter()
  keybinds.treesitter_textobjects()
  vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    pattern = { "*" },
    callback = function()
      vim.treesitter.start()
    end,
  })
end
