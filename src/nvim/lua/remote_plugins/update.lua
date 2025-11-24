local M = {}

function M.update_index()
    local cache = require("remote_plugins.cache")
    local Job = require("plenary.job")

    local j = Job:new({
        command = "curl",
        args = { "https://nvim.sh/s?format=json" },
        on_exit = function(j, _)
            vim.schedule_wrap(function()
                cache.write(j:result())
            end)()
        end
    })

    j:start()

    return j
end

function M.setup()
end

return M
