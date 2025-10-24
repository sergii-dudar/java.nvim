local M = {}

M.is_buffer_to_ignore = function()
    if string.match(vim.api.nvim_buf_get_name(0), "neo%-tree filesystem") then
        vim.notify("skipped neo-tree buffer")
        return true
    end
    return false
    -- lua print(vim.api.nvim_buf_get_name(0))
    -- vim.notify("[simaxme-java] Neo-tree buffer name: " .. vim.api.nvim_buf_get_name(0), vim.log.levels.INFO)
end

return M
