return function()
    -- @dap

    local dap = require("dap")
    require("hook.keybind").hooks.dap()

    local dapui = require("dapui");
    require("nvim-dap-virtual-text").setup({});

    dapui.setup();
    dap.listeners.before.attach.dapui_config = function()
        dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
        dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
    end

    dap.configurations.javascript = {
        {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch Current File (pwa-node)',
            program = '${file}',
            cwd = '${workspaceFolder}',
            protocol = 'inspector',
        },
    }

    dap.configurations.typescript = {
        {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch Current File (pwa-node with ts-node)',
            program = '${file}',
            runtimeArgs = { '--loader=ts-node/esm', '--port', '4444' },
            runtimeExecutable = 'node',
            cwd = vim.fn.getcwd(),
            --args = { '--inspect', '${file}' },
            sourceMaps = true,
            protocol = 'inspector',
            outFiles = { '${workspaceFolder}/**/*', "!**/node_modules/**" },
            skipFiles = { '<node_internals>/**', 'node_modules/**' },
            resolveSourceMapLocations = {
                "${workspaceFolder}/**",
                "!**/node_modules/**",
            },
        },
    };
end
