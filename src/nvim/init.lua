local function init()
    local utils = require("init_all.utils")

    utils.try_setup(require("init_all"))

    if utils.has_errors() then
        utils.show_errors()
    end
end

local ok, err = pcall(init)

if not ok then
    require("init_all.utils").show_errors({ err })
end
