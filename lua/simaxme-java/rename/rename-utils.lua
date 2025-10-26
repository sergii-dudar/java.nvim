local M = {}

local options = require("simaxme-java.options")
local java_rename = require("simaxme-java.rename")
local utils = require("simaxme-java.rename.utils")

---@param data {old_name: string, new_name: string}
M.make_rename = function(data)
    -- vim.cmd("wincmd l") -- TODO: temp
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

M.switch_to_buffer = function(file_path)
    -- Normalize to absolute path
    local abs_path = vim.fn.fnamemodify(file_path, ":p")

    -- Try to find an existing buffer for this path
    local bufnr = vim.fn.bufnr(abs_path)

    if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) then
        -- ✅ Buffer exists and is loaded → switch to it
        vim.api.nvim_set_current_buf(bufnr)
    else
        -- ⚙️ Not loaded or doesn't exist → open file (this creates buffer)
        vim.cmd.edit(abs_path)
        bufnr = vim.api.nvim_get_current_buf()
    end

    return bufnr
end

M.ensure_buffer_loaded = function(filepath)
    -- vim.fn.bufloaded() checks if a buffer for the file exists and is loaded.
    -- It returns the buffer number if it is, or 0 if it is not.
    local bufnr = vim.fn.bufloaded(filepath)

    -- If the buffer is not loaded (bufnr is 0)
    if bufnr == 0 then
        -- vim.fn.bufadd() adds the file to the buffer list without loading it
        -- or switching to it. It returns the new buffer number.
        bufnr = vim.fn.bufadd(filepath)

        -- vim.fn.bufload() loads the content of the buffer from the file.
        -- This does not affect the current window or focus.
        vim.fn.bufload(bufnr)
    end

    return bufnr
end

-- local function load_buffer_if_not_loaded(file_path)
--     -- Check if buffer already exists for this file
--     local bufnr = vim.fn.bufnr(file_path)
--     if bufnr == -1 then
--         -- Buffer doesn't exist, create it silently
--         vim.cmd.silent(string.format("edit %s", vim.fn.fnameescape(file_path)))
--         bufnr = vim.fn.bufnr(file_path)
--     end
--     return bufnr
-- end

M.cleanup_old_file = function(old_file_name)
    local abs_path = vim.fn.fnamemodify(old_file_name, ":p")
    local bufnr = vim.fn.bufnr(abs_path)

    -- 1. Try to delete the old file from disk
    if vim.fn.filereadable(abs_path) == 1 then
        os.remove(abs_path)
    end

    -- 2. If buffer still exists, wipe it
    if bufnr ~= -1 then
        -- force wipe to remove even unloaded/hidden buffers
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end
end

return M
