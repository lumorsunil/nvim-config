return require("telescope").register_extension({
    setup = function()
        require("remote_plugins").setup()
    end,
    exports = {
        remote_plugins = require("remote_plugins.picker").picker,
    },
    health = require("remote_plugins.health").check
})
