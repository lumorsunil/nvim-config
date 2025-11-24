return {
    setup = function()
        -- @pre-lazy

        vim.g.zig_fmt_parse_errors = 0

        -- @lazy

        local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
        if not vim.loop.fs_stat(lazypath) then
            vim.fn.system({
                "git",
                "clone",
                "--filter=blob:none",
                "https://github.com/folke/lazy.nvim.git",
                "--branch=stable", -- latest stable release
                lazypath,
            })
        end
        vim.opt.rtp:prepend(lazypath)

        require("lazy").setup("plugins", {
            defaults = {
                lazy = true,
            },
            install = {
                missing = true,
            },
            change_detection = {
                enabled = false,
            },
        })
    end
}
