local oilNvimIntegration = {}

-- Initialize Neo-tree integration:
-- Subscribes to "file_renamed" and "file_moved" events
function oilNvimIntegration.setup()
    local rename_utils = require("simaxme-java.rename.rename-utils")
    local oilNvimMakeRename = function(aold_name, anew_name)
        local old_name = aold_name:gsub("^oil://", "")
        local new_name = anew_name:gsub("^oil://", "")
        -- vim.notify("[java-raname] oil.nvim " .. old_name .. " -> " .. new_name, vim.log.levels.INFO)
        rename_utils.switch_to_buffer(old_name)
        rename_utils.make_rename({
            old_name = old_name,
            new_name = new_name,
        })
        vim.api.nvim_win_close(0, false) -- close oil floating window (with loaded new version of file, just as workaround)
        rename_utils.cleanup_old_file(old_name)
        vim.notify("[simaxme-java(oil.nvim)] operation successful", vim.log.levels.INFO)
    end

    vim.api.nvim_create_autocmd("User", {
        pattern = "OilActionsPost",
        callback = function(event)
            local action = event.data.actions[1]
            -- vim.notify(
            --     "[java-raname] oil.nvim: type - [" .. action.type .. "] " .. vim.inspect(action),
            --     vim.log.levels.INFO
            -- )
            if action.type == "move" then
                oilNvimMakeRename(action.src_url, action.dest_url)
            end
        end,
    })

    -- vim.notify("[java-raname] oil.nvim integration enabled", vim.log.levels.INFO)
end

return oilNvimIntegration
