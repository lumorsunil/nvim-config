local M = {}

local function is_open_in_editor(uri)
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if uri == vim.uri_from_bufnr(bufnr) then
            return true
        end
    end
    return false
end

local function is_ignored_by_scm(_, file_uri)
    local uri = type(file_uri) == "table" and file_uri[1] or file_uri
    local bufnr = vim.uri_to_bufnr(uri)
    local ok, gitsigns_status = pcall(function()
        return vim.api.nvim_buf_get_var(bufnr, "gitsigns_status_dict")
    end)

    if not ok then
        -- Assuming that there is no SCM because gitsigns is not available
        return false
    end

    return not gitsigns_status.added
end

local function get_settings()
    local settings = {}
    settings.analyzerProperties = {}
    local analyzer_properties_fn = "sonar-project.properties"
    if vim.fn.filereadable(analyzer_properties_fn) then
        local analyzer_properties = vim.fn.readfile(analyzer_properties_fn)
        for _, line in ipairs(analyzer_properties) do
            if not line:find("^%s*#") and not line:find("^%s*$") then
                local s = vim.fn.split(line, "=")
                if #s ~= 2 then
                    error("Unable to parse: " .. line)
                end
                local key = s[1]
                local value = s[2]
                settings.analyzerProperties[key] = value
            end
        end
    end
    return settings
end

function M.get_lsp_config()
    local config = {}


    config.name = "sonarlintls"
    config.cmd = { "sonarlint-language-server", "--typescript" }
    config.root_dir = vim.fn.getcwd()
    config.capabilities = vim.lsp.protocol.make_client_capabilities()
    config.settings = { sonarlint = {} }

    config.handlers = {}

    config.handlers["sonarlint/shouldAnalyseFile"] = function(_, uri)
        return {
            shouldBeAnalysed = is_open_in_editor(uri.uri),
        }
    end

    config.handlers["sonarlint/isIgnoredByScm"] = is_ignored_by_scm

    local on_init = config.on_init
    config.on_init = function(...)
        local client = select(1, ...)
        local settings = get_settings()

        client.notify("workspace/didChangeConfiguration", {
            settings = settings,
        })
        if on_init then on_init(...) end
    end

    return config
end

return M
