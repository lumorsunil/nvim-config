local previewers = require("telescope.previewers")

local previewer = previewers.new_buffer_previewer({
    define_preview = function(self, entry, status)
        vim.fn.setbufline(self.state.bufnr, 1, {
            entry.value.plugin.name .. " - " .. entry.value.plugin.id,
            "",
            entry.value.plugin.description,
            "",
            entry.value.plugin.link,
        })
    end
})

return previewer
