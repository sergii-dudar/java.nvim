local M = {}

local rename_utils = require("simaxme-java.rename.rename-utils")
local snacksNvimMakeRename = function(old_name, new_name)
    vim.notify("[java-raname] snacks.nvim " .. old_name .. " -> " .. new_name, vim.log.levels.INFO)
    rename_utils.switch_to_buffer(old_name)
    rename_utils.make_rename({
        old_name = old_name,
        new_name = new_name,
    })
    rename_utils.cleanup_old_file(old_name)
    rename_utils.switch_to_buffer(new_name)
    vim.notify("[simaxme-java(snacks.nvim rename)] operation successful", vim.log.levels.INFO)
end

M.rename_current = function()
    Snacks.rename.rename_file({
        on_rename = function(new, old)
            snacksNvimMakeRename(old, new)
        end,
    })
end

-- vim.notify("[java-raname] snacks.nvim integration enabled", vim.log.levels.INFO)

return M
