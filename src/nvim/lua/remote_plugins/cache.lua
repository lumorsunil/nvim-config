local M = {}

local json = require("json")

---@type nil | { rank: number, plugin: { createdAt: string, updatedAt: string, watcher: number, description: string, branch: string, username: string, repo: string, name: string, homepage: string, openIssues: number, forks: number, link: string, stars: number, tags: table, subscribers: number, id: string, network: number } }[]
local mem_cache = nil

local function get_base()
    return vim.fn.stdpath("cache") .. "/remote_plugins"
end

local function get_path()
    return get_base() .. "/list.json"
end

local function exists()
    return vim.fn.filereadable(get_path())
end

local function is_array(data)
    return (type(data) == "table") and data[1] ~= nil
end

---@param data string[]
local function postprocess(data)
    local s = table.concat(data)
    ---@type { results: { rank: number, plugin: { createdAt: string, updatedAt: string, watcher: number, description: string, branch: string, username: string, repo: string, name: string, homepage: string, openIssues: number, forks: number, link: string, stars: number, tags: table, subscribers: number, id: string, network: number } }[] }
    local decoded = json.decode(s)

    if (type(decoded) ~= "table") then
        error("remote_plugins data is not a table")
    end

    if (not is_array(decoded.results)) then
        error("remote_plugins data.results not an array")
    end

    return decoded.results
end

local function write(data)
    vim.fn.mkdir(get_base(), "p")
    vim.fn.writefile(data, get_path())
    mem_cache = M.read()
end

local function read()
    if (mem_cache ~= nil) then
        return mem_cache
    end
    if (exists() == 0) then
        return {}
    end
    local file_cache = vim.fn.readfile(get_path())
    mem_cache = postprocess(file_cache)
    return mem_cache
end

local function setup()
end

M.write = write
M.read = read
M.exists = exists
M.setup = setup

return M
