local configs = require("plugins-configs")
local keybinds = require("hook.keybind").hooks

---@type table<string, LazySpec>
local lazy_specs = {
    transparent = {
        enabled = false,
        "xiyaowong/transparent.nvim",
        lazy = false,
        opts = {},
        --enabled = false
    },
    lspkind = {
        enabled = true,
        "onsails/lspkind.nvim",
    },
    cmp = {
        enabled = true,
        "hrsh7th/nvim-cmp",
        main = "cmp",
        event = "User InitAllDone",
        config = configs.cmp,
        dependencies = {
            "hrsh7th/cmp-vsnip",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "hrsh7th/cmp-cmdline",
            "onsails/lspkind.nvim",
        },
    },
    vsnip = {
        enabled = true,
        "hrsh7th/cmp-vsnip",
        event = "User InitAllDone",
        dependencies = {
            "hrsh7th/vim-vsnip",
            "rafamadriz/friendly-snippets",
        },
    },
    dap = {
        enabled = true,
        "mfussenegger/nvim-dap",
        event = "User InitAllDone",
        mode = "",
        config = configs.dap,
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
        },
    },
    dap_ui = {
        enabled = true,
        "rcarriga/nvim-dap-ui",
        event = "User InitAllDone",
        dependencies = {
            "nvim-neotest/nvim-nio",
        },
    },
    smart_open = {
        enabled = true,
        "danielfalk/smart-open.nvim",
        lazy = false,
        priority = 999,
        branch = "0.2.x",
        config = function()
            require("telescope").load_extension("smart_open")
        end,
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "kkharji/sqlite.lua",
            "nvim-telescope/telescope-fzf-native.nvim",
        },
    },
    fzf = {
        enabled = true,
        "nvim-telescope/telescope-fzf-native.nvim",
        lazy = false,
        priority = 999,
        build = 'make'
    },
    json = {
        enabled = true,
        "rxi/json.lua",
        event = "User InitAllDone",
        build = function()
            local p = vim.fn.stdpath("data") .. "/lazy/json.lua"
            vim.cmd(":!mkdir -p " .. p .. "/lua/json")
            vim.cmd(":!ln -s " .. p .. "/json.lua " .. p .. "/lua/json/init.lua")
        end,
    },
    lspconfig = {
        enabled = true,
        "neovim/nvim-lspconfig",
        event = "User InitAllDone",
        config = configs.lsp,
        dependencies = {
            "folke/neodev.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "yioneko/nvim-vtsls",
        },
    },
    rest = {
        enabled = false,
        "rest-nvim/rest.nvim",
        --enabled = false,
        event = "User InitAllDone",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = configs.rest,
    },
    telescope = {
        enabled = true,
        "nvim-telescope/telescope.nvim",
        lazy = false,
        priority = 999,
        tag = '0.1.5',
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-fzf-native.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-telescope/telescope-ui-select.nvim",
            "axkirillov/easypick.nvim",
        },
        config = configs.telescope,
    },
    tree = {
        enabled = false,
        "nvim-tree/nvim-tree.lua",
        cmd = { "NvimTreeOpen", "NvimTreeFindFile", "NvimTreeClose" },
        keys = keybinds.tree(),
        dependencies = "nvim-tree/nvim-web-devicons",
        config = configs.tree,
    },
    treesitter = {
        enabled = true,
        "nvim-treesitter/nvim-treesitter",
        event = "User InitAllDone",
        config = configs.treesitter,
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            --"nvim-treesitter/nvim-treesitter-context",
        },
    },
    url_open = {
        enabled = true,
        "sontungexpt/url-open",
        cmd = "URLOpenUnderCursor",
        config = configs.urlopen,
    },
    devicons = {
        enabled = true,
        "nvim-tree/nvim-web-devicons",
        event = "User InitAllDone",
    },
    autopairs = {
        enabled = true,
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {},
    },
    --{
    --    "akinsho/bufferline.nvim",
    --    version = "*",
    --    dependencies = { "nvim-tree/nvim-web-devicons" },
    --    config = configs.bufferline,
    --},
    gitsigns = {
        enabled = true,
        "lewis6991/gitsigns.nvim",
        event = "User InitAllDone",
        config = configs.gitsigns,
    },
    tokyonight = {
        enabled = true,
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    },
    melange = {
        enabled = true,
        "savq/melange-nvim",
        lazy = false,
        priority = 1000,
        config = function() end,
    },
    miasma = {
        enabled = true,
        "xero/miasma.nvim",
        lazy = false,
        priority = 1000,
        config = function() end,
    },
    lualine = {
        enabled = true,
        "nvim-lualine/lualine.nvim",
        event = "User InitAllDone",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = configs.lualine,
    },
    rainbow = {
        enabled = true,
        "HiPhish/rainbow-delimiters.nvim",
        event = "User InitAllDone",
        config = configs.rainbow,
    },
    toggleterm = {
        enabled = true,
        "akinsho/toggleterm.nvim",
        cmd = "ToggleTerm",
        keys = keybinds.terminal(),
        version = "*",
        config = configs.terminal,
    },
    cloak = {
        enabled = true,
        "laytan/cloak.nvim",
        event = "User InitAllDone",
        config = configs.cloak,
    },
    colorizer = {
        enabled = true,
        "NvChad/nvim-colorizer.lua",
        event = "BufReadPost *.css,*.scss,*.less,*.html,*.jsx,*.tsx",
        config = configs.colorizer,
    },
    twilight = {
        enabled = true,
        "folke/twilight.nvim",
        cmd = "Twilight",
        keys = keybinds.twilight(),
        config = configs.twilight,
    },
    which_key = {
        enabled = true,
        "folke/which-key.nvim",
        event = "User InitAllDone",
        config = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
            require("which-key").setup({})
            keybinds.which_key()
        end,
    },
    illuminate = {
        enabled = false,
        "RRethy/vim-illuminate",
        event = "User InitAllDone",
        config = configs.illuminate,
    },
    prettier = {
        enabled = true,
        "MunifTanjim/prettier.nvim",
        event = "User InitAllDone",
        config = function()
            require("prettier").setup({})
        end,
    },
    dap_vscode = {
        enabled = false,
        "mxsdev/nvim-dap-vscode-js",
        --enabled = false,
        event = "User InitAllDone",
        keys = keybinds.dap_enable(),
        dependencies = { "microsoft/vscode-js-debug" },
        config = function()
            -- The defaults are not marked as optional in this plugin
            ---@diagnostic disable-next-line: missing-fields
            require("dap-vscode-js").setup({
                debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
                adapters = { 'pwa-node' },
            })
        end,
    },
    vscode_js_debug = {
        enabled = false,
        "microsoft/vscode-js-debug",
        --enabled = false,
        lazy = true,
        build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
    },
    vtsls = {
        enabled = true,
        "yioneko/nvim-vtsls",
        event = "User InitAllDone",
        config = function()
            require("vtsls").config({})
        end,
    },
    neotest = {
        enabled = true,
        "nvim-neotest/neotest",
        lazy = true,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter"
        },
    },
    diffview = {
        enabled = true,
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewFileHistory" },
        config = function()
            require("diffview").setup({
                keymaps = keybinds.diffview()
            })
        end,
    },
    blame_line = {
        enabled = true,
        "tveskag/nvim-blame-line",
        cmd = "EnableBlameLine",
    },
    lint = {
        enabled = false,
        "mfussenegger/nvim-lint",
        --enabled = false,
        event = "BufWritePost",
        config = function()
            local lint = require('lint')
            vim.api.nvim_create_augroup("Lint", {})
            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                pattern = { "*" },
                callback = function()
                    local _, err = pcall(lint.try_lint)
                    if err then
                        vim.print("error while linting:", err)
                    end
                end
            })
        end,
    },
    easypick = {
        enabled = true,
        "axkirillov/easypick.nvim",
        config = function() end
    },
    flash = {
        enabled = true,
        "folke/flash.nvim",
        ---@type Flash.Config
        opts = {},
        keys = keybinds.flash(),
    },
    outline = {
        enabled = false,
        "hedyhli/outline.nvim",
        event = "User InitAllDone",
        keys = keybinds.outline(),
        config = configs.outline,
    },
    perfanno = {
        enabled = true,
        "t-troebst/perfanno.nvim",
        keys = keybinds.perfanno(),
        config = function()
            local perfanno = require("perfanno")
            local util = require("perfanno.util")
            local bgcolor = vim.fn.synIDattr(vim.fn.hlID("Normal"), "bg", "gui")
            perfanno.setup({
                line_highlights = util.make_bg_highlights(bgcolor, "#CC3300", 10),
                vt_highlight = util.make_fg_highlight("#CC3300"),
            })
        end
    },
    lush = {
        enabled = true,
        "rktjmp/lush.nvim",
        cmd = { "LushRunTutorial", "Lushify" },
        init = function()
            vim.api.nvim_create_user_command("LushCompile", function(opts)
                require("lush")
                local lushwright = require("shipwright.transform.lush")
                local shipwright = require("shipwright")
                local patchwrite = require("shipwright.transform.patchwrite")

                local theme_name = opts.args
                if theme_name == "%" then theme_name = vim.fn.expand("%:t:r") end

                local root = vim.fn.getcwd() .. "/src/nvim"

                local colorscheme_template = root .. "/lua/colors_src/colorscheme_template.lua"
                local colorscheme_src = "colors_src.src." .. theme_name
                local target_colorscheme = root .. "/colors/" .. theme_name .. ".lua"

                vim.fn.system([[echo "local colors_name = ']] .. theme_name .. [['" > "]] .. target_colorscheme .. [["]])
                vim.fn.system([[cat "]] .. colorscheme_template .. [[" >> "]] .. target_colorscheme .. [["]])

                shipwright.run(
                    require(colorscheme_src),
                    lushwright.to_lua,
                    { patchwrite, target_colorscheme, "-- PATCH_OPEN", "-- PATCH_CLOSE" }
                )

                vim.cmd.colorscheme(vim.api.nvim_get_var("colors_name"))
            end, { nargs = 1, force = true })
        end,
        config = function()
            local lush = require("lush")
            vim.api.nvim_create_user_command("Lushify", function()
                require("colors_src").disable()
                lush.ify()
                vim.keymap.set("n", "<leader>li",
                    "<cmd>redir @\" | silent exe 'Inspect' | redir END | silent normal! p <cr>")
            end, { force = true })
        end,
        dependencies = {
            "rktjmp/shipwright.nvim",
        },
    },
    vscode = {
        enabled = true,
        "Mofiqul/vscode.nvim",
        ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    },
    go = {
        enabled = true,
        "ray-x/go.nvim",
        dependencies = { -- optional packages
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("go").setup()
        end,
        event = "User InitAllDone",
        ft = { "go", 'gomod' },
        build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
    },
    overseer = {
        enabled = true,
        "stevearc/overseer.nvim",
        event = "User InitAllDone",
        config = configs.overseer
    },
    markdown_preview = {
        enabled = true,
        "iamcco/markdown-preview.nvim",
        ft = { "markdown", "pandoc.markdown", "rmd" },
        build = "cd app && npm install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
            vim.g.mkdp_port = '43260'
            vim.g.mkdp_browser = 'google-chrome'
            vim.g.mkdp_open_to_the_world = true
            vim.g.mkdp_echo_preview_url = true
        end,
    },
    runic = {
        dir = "/home/lumorsunil/repos/runic/editor/neovim",
        name = "runic-highlighter",
        ft = "runic",
        opts = {},
        config = function(_, opts)
            require("runic_highlight").setup(opts)
        end,
    },
}

local plugins = {}

for _, plugin in pairs(lazy_specs) do
    table.insert(plugins, plugin)
end

return plugins
