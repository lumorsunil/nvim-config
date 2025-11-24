return {
    setup = function()
        local ok, utils = pcall(require, "init_all.utils")
        if not ok then
            print("error loading init_all.utils: " .. utils)
            return
        end
        local try_setup = utils.try_setup

        -- @init_all
        try_setup(require("init_all.version_check"))
        try_setup(require("init_all.init_keybindings"))
        try_setup(require("init_all.init_lazy"))
        try_setup(require("colors_src"))
        try_setup(require("init_all.init_vim"))
        try_setup(require("init_all.init_remoteplugins"))
        try_setup(require("daily-todos"))
        try_setup(require("short-context-switch"))
        try_setup(require("pms"))
        try_setup(require("twitch"))
        try_setup(require("newb"))
        try_setup(require("ai"))

        --try_setup(require("dashboard"))

        vim.api.nvim_create_autocmd({ "VimEnter" }, {
            once = true,
            callback = function()
                vim.fn.timer_start(100, function()
                    vim.cmd [[doautocmd User InitAllDone]]
                end)
            end
        })
    end
}
