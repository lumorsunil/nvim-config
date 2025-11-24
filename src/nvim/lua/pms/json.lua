local M = {}

---@param json_string string
function M.parse_flat_json_object(json_string)
    local object = {}

    local parser = vim.treesitter.get_string_parser(json_string, "json")
    local root = parser:parse()[1]:root()
    local query = vim.treesitter.query.parse("json",
        [[(pair
    key: (string (string_content) @key)
    value: (string (string_content) @value)
)]])

    local key
    for id, capture, _ in query:iter_captures(root, json_string, 0, 0) do
        local text = vim.treesitter.get_node_text(capture, json_string)
        if id == 1 then
            key = text
        else
            object[key] = text
        end
    end

    return object
end

return M
