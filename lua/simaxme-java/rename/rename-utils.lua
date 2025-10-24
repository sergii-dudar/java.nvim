local M = {}

local options = require("simaxme-java.options")
local java_rename = require("simaxme-java.rename")
local utils = require("simaxme-java.rename.utils")

---@param data {old_name: string, new_name: string}
M.make_rename = function(data)
    local regex = "%.java$"

    local is_java_file = string.find(data.old_name, regex) ~= nil and string.find(data.new_name, regex) ~= nil

    if not is_java_file then
        local root_markers = options.get_java_options().root_markers

        -- find the relative root path by splitting the array, which is defined by options.root_markers
        local parts = utils.split_with_patterns(data.old_name, root_markers)

        -- if any of the root markers could not be found, cancel
        if #parts <= 1 then
            return nil
        end
    end

    local old_name = data.old_name
    local new_name = utils.realpath(data.new_name)
    vim.notify("NEW_NAME: " .. new_name, vim.log.levels.INFO)

    local is_dir = utils.is_dir(new_name)

    if not is_dir then
        java_rename.on_rename_file(old_name, new_name)
        vim.notify("Neo-tree (dir) file moved from: " .. old_name .. ", to " .. new_name, vim.log.levels.INFO)
    else
        local files = utils.list_folder_contents_recursive(new_name)

        vim.notify("Neo-tree file renamed/moved... from: " .. old_name .. ", to " .. new_name, vim.log.levels.INFO)
        for i, file in ipairs(files) do
            local old_file = old_name .. "/" .. file
            local new_file = new_name .. "/" .. file

            java_rename.on_rename_file(old_file, new_file, true)
        end
        vim.notify("Neo-tree file renamed/moved from: " .. old_name .. ", to " .. new_name, vim.log.levels.INFO)
    end
end

return M
