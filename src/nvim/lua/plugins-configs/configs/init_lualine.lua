return function()
  require("lualine").setup({
    sections = {
      lualine_x = {
        {
          require("init_all.sessions-statusline").statusline_session,
          color = { fg = "#ff007c", gui = "bold" }, -- Optional style highlight
        },
        "encoding",
        "fileformat",
        "filetype",
      },
    },
  })
end
