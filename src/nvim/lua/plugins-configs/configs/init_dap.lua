return function()
    -- @dap

    local dap = require("dap")
    dap.listeners.after.event_initialized['me.dap.keys'] = require("hook.keybind").hooks.dap
    dap.listeners.after.event_terminated['me.dap.keys'] = require("hook.keybind").hooks.dap_reset
    -- dap.listeners.after.disconnected['me.dap.keys'] = require("hook.keybind").hooks.dap_reset

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

    -- local codelldbPort = "4111"

    -- dap.adapters.codelldb = {
    --     type = 'server',
    --     host = "127.0.0.1",
    --     port = "${port}",
    --     executable = {
    --         -- command = "/home/lumorsunil/.vscode-oss/extensions/vadimcn.vscode-lldb-1.11.4/adapter/codelldb",
    --         command = "codelldb",
    --         args = { "--port", "${port}", "--liblldb", "/home/lumorsunil/repos/dungeon-crawler/LLVM-19.1.0-Linux-X64/lib/liblldb.so.19.1.0" },
    --     }
    --     -- type = 'executable',
    --     -- command = "codelldb",
    --     -- args = {},
    --     -- command = "bash",
    --     -- args = { vim.fn.expand("~/repos/dungeon-crawler/codelldb.sh"), "--port", "${port}" },
    -- }

    -- dap.adapters.codelldb = {
    --     type = "server",
    --     port = codelldbPort,
    --     executable = {
    --         command =
    --         "codelldb",
    --         args = { "--port", codelldbPort },
    --     },
    -- };

    dap.adapters.lldb = {
        type = 'executable',
        -- command = '/home/lumorsunil/repos/dungeon-crawler/LLVM-22.1.8-Linux-X64/bin/lldb-dap',
        command = '/mnt/d/dev/clang+llvm-18.1.8-x86_64-pc-windows-msvc/bin/lldb-dap.exe',
        name = 'lldb'
    }

    dap.configurations.zig = {
        {
            name = "Launch",
            type = "lldb",
            request = "launch",
            -- program = "zig-out/bin/${workspaceFolderBasename}.exe",
            program = function()
                -- Automatically looks into the default Zig build output directory
                return vim.fn.getcwd() .. '/zig-out/bin/${workspaceFolderBasename}.exe'
            end,
            -- cwd = '${workspaceFolder}',
            stopOnEntry = true,
            -- sourcePath = '${workspaceFolder}',
            initCommands = {
                "settings set target.disable-aslr false",
                -- "settings set target.source-map . ${workspaceFolder}"
            }
        },
    };
end
