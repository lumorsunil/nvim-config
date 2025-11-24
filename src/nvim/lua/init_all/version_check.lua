return {
    setup = function()
        local range = "^0.10.0"

        local r = vim.version.range(range)
        local nvimVersion = vim.fn.matchstr(vim.fn.execute('version'), 'NVIM v\\zs[^\\n]*')

        if not r:has(nvimVersion) then
            vim.cmd.echoe(string.format("'nvim version %s not matching supported version %s'", nvimVersion, range))
        end
    end
}
