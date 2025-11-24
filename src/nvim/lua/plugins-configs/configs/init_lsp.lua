local fs = require "fs"
---Loads LSP if current filetype is already a match, otherwise sets up a FileType autocommand that loads the LSP.
---It also runs :LspStart after the LSP has been loaded.
---@param group string|number
---@param filetype_pattern string[]
---@param callback fun()
local function setup_lsp_loader(group, filetype_pattern, callback)
    local callback_with_lspstart = function()
        callback()
        vim.cmd [[LspStart]]
    end

    local found = vim.fn.index(filetype_pattern, vim.bo.filetype)
    if found > -1 then
        callback_with_lspstart()
        return
    end

    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = filetype_pattern,
        once = true,
        callback = callback_with_lspstart,
    })
end

return function()
    -- @lsp

    local group = vim.api.nvim_create_augroup('UserLspConfig', {})

    -- Use LspAttach autocommand to only map the following keys
    -- after the language server attaches to the current buffer
    vim.api.nvim_create_autocmd('LspAttach', {
        group = group,
        callback = function(ev)
            -- Enable completion triggered by <c-x><c-o>
            vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
            require("hook.keybind").hooks.lsp({ buffer = ev.buf })
        end,
    })

    local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
    local default_opts = { capabilities = capabilities }
    -- lua lsp for neovim config
    require("neodev").setup({
        -- This line messes up lua lsp, it starts to skip loading library files
        --library = { plugins = { "neotest" }, types = true },
    })
    local lspconfig = require("lspconfig")
    setup_lsp_loader(group, { "lua" }, function()
        lspconfig.lua_ls.setup(vim.tbl_deep_extend("force", default_opts, {
            settings = {
                Lua = {
                    runtime = {
                        version = "LuaJIT",
                    },
                    workspace = {
                        maxPreload = 65535,
                        preloadFileSize = 65535,
                    },
                },
            },
        }))
    end)
    setup_lsp_loader(group, { "javascript", "javascriptreact", "typescript", "typescriptreact" }, function()
        lspconfig.vtsls.setup(vim.tbl_deep_extend("force", default_opts, require("vtsls").lspconfig))
    end)
    --lspconfig.tsserver.setup(default_opts)
    setup_lsp_loader(group, { "bash", "sh" }, function()
        lspconfig.bashls.setup(default_opts)
    end)
    setup_lsp_loader(group, { "markdown" }, function()
        lspconfig.marksman.setup(default_opts)
    end)
    setup_lsp_loader(group, { "odin" }, function()
        lspconfig.ols.setup(vim.tbl_deep_extend("force", default_opts, {
            cmd = { os.getenv("HOME") .. "/ols/ols" },
        }))
    end)
    setup_lsp_loader(group, { "json", "jsonc" }, function()
        lspconfig.jsonls.setup(default_opts)
    end)
    setup_lsp_loader(group, { "go", "gomod", "gotmpl", "gowork", "gohtmltmpl", "gotexttmpl" }, function()
        lspconfig.gopls.setup(default_opts);
        vim.cmd [[LspStart]]
    end)
    setup_lsp_loader(group, { "zig" }, function()
        vim.diagnostic.config({
            float = false,
            update_in_insert = false,
            virtual_text = false,
            signs = false,
            underline = false,
        })
        lspconfig.zls.setup(vim.tbl_deep_extend("force", default_opts, {
            settings = {
                zls = {
                    enable_build_on_save = true,
                    build_on_save_alternative_watch = true,
                    semantic_tokens = "partial",
                },
            },
        }));
        -- vim.api.nvim_create_autocmd("BufWritePre", {
        --     pattern = { "*.zig", "*.zon" },
        --     callback = function()
        --         vim.lsp.buf.code_action({
        --             context = {
        --                 only = { "source.fixAll" },
        --                 diagnostics = {},
        --             },
        --             apply = true,
        --         })
        --         vim.lsp.buf.code_action({
        --             context = {
        --                 only = { "source.organizeImports" },
        --                 diagnostics = {},
        --             },
        --             apply = true,
        --         })
        --     end
        -- })
    end)
    -- js lint
    -- SonarLint (disabled since it doesn't work)
    setup_lsp_loader(group, { "javascript", "javascriptreact", "typescript", "typescriptreact" }, function()
        local configJsExists = fs.file_exists("eslint.config.js")
        local configRcExists = fs.file_exists(".eslintrc")
        local packageJsonExists = fs.file_exists("package.json")
        local eslintConfigInPackageJson = false
        if (packageJsonExists) then
            local packageJson = vim.fn.readfile("package.json")
            if vim.fn.match(packageJson, "eslintConfig") > 0 then
                eslintConfigInPackageJson = true
            end
        end
        if (not configRcExists and not configJsExists and not eslintConfigInPackageJson) then return end

        local shouldUseFlatConfig = configJsExists
        local rootDir

        if configJsExists then
            rootDir = lspconfig.util.root_pattern("eslint.config.js")
        elseif configRcExists then
            rootDir = lspconfig.util.root_pattern(".eslintrc")
        elseif eslintConfigInPackageJson then
            rootDir = lspconfig.util.root_pattern("package.json")
        end

        lspconfig.eslint.setup(vim.tbl_deep_extend("force", default_opts, {
            handlers = {
                ["eslint/confirmESLintExecution"] = function(args)
                    vim.print("eslint/confirmESLintExecution")
                    vim.print(vim.inspect(args))
                end,
                ["eslint/noLibrary"] = function(args)
                    vim.print("eslint/noLibrary")
                    vim.print(vim.inspect(args))
                end,
                ["eslint/openDoc"] = function(args)
                    vim.print("eslint/openDoc")
                    vim.print(vim.inspect(args))
                end,
                ["eslint/probeFailed"] = function(args)
                    vim.print("eslint/probeFailed")
                    vim.print(vim.inspect(args))
                end,
                ["eslint/noConfig"] = function(args)
                    vim.print("eslint/noConfig")
                    vim.print(vim.inspect(args))
                end,
            },
            settings = {
                validate = "on",
                useFlatConfig = shouldUseFlatConfig,
                experimental = {
                    useFlatConfig = shouldUseFlatConfig
                },
            },
            root_dir = rootDir,
            filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        }))
        --vim.lsp.start(require("sonarlintls").get_lsp_config())
    end);

    local configs = require 'lspconfig.configs'
    local runic_cmd = '/home/lumorsunil/repos/runic/zig-out/bin/runic-lsp'

    -- Check if the config is already defined (useful when reloading this file)
    if not configs.runic_lsp then
        configs.runic_lsp = {
            default_config = {
                cmd = { runic_cmd },
                cmd_env = { RUNIC_LSP_LOG = 1 },
                filetypes = { 'runic' },
                root_dir = function(fname)
                    return vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1]);
                end,
                settings = {},
            },
        }
    end
    setup_lsp_loader(group, { "runic" }, function()
        lspconfig.runic_lsp.setup(default_opts)
    end)
end
