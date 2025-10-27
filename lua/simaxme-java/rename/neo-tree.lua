local neoTreeIntegration = {}

-- Initialize Neo-tree integration:
-- Subscribes to "file_renamed" and "file_moved" events
function neoTreeIntegration.setup()
    local ok, events = pcall(require, "neo-tree.events")
    if not ok then
        vim.notify("[simaxme-java] Neo-tree not found", vim.log.levels.WARN)
        return
    end

    local rename_utils = require("simaxme-java.rename.rename-utils")
    local neoTreeMakeRename = function(data)
        rename_utils.switch_to_buffer(data.source)
        vim.schedule(function()
            rename_utils.make_rename({
                old_name = data.source,
                new_name = data.destination,
            })
            vim.schedule(function()
                rename_utils.cleanup_old_file(data.source)
                vim.notify("[simaxme-java(neo-tree)] operation successful", vim.log.levels.INFO)
            end)
        end)
    end

    events.subscribe({
        event = events.FILE_RENAMED,
        handler = neoTreeMakeRename,
    })

    -- Neo-tree 3.x and newer emits separate move events (rename covers both, but just in case)
    if events.FILE_MOVED then
        events.subscribe({
            event = events.FILE_MOVED,
            handler = neoTreeMakeRename,
        })
    end

    -- vim.notify("[simaxme-java] Neo-tree integration enabled", vim.log.levels.INFO)
end

return neoTreeIntegration
