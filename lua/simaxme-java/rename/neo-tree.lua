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

    events.subscribe({
        event = events.FILE_RENAMED,
        handler = function(data)
            vim.notify(
                "[simaxme-java] Neo-tree file renaming from: " .. data.source .. ", to " .. data.destination,
                vim.log.levels.INFO
            )

            vim.schedule(function()
                rename_utils.make_rename({
                    old_name = data.source,
                    new_name = data.destination,
                })
            end)

            vim.notify(
                "[simaxme-java] Neo-tree file renamed from: " .. data.source .. ", to " .. data.destination,
                vim.log.levels.INFO
            )

            -- local timer = vim.uv.new_timer()
            -- timer:start(
            --     3000,
            --     0,
            --     vim.schedule_wrap(function()
            --         vim.schedule(function()
            --         end)
            --         timer:close()
            --     end)
            -- )
        end,
    })

    -- Neo-tree 3.x and newer emits separate move events (rename covers both, but just in case)
    -- if events.FILE_MOVED then
    --     events.subscribe({
    --         event = events.FILE_MOVED,
    --         handler = function(data)
    --             rename_utils.make_rename({
    --                 old_name = data.source,
    --                 new_name = data.destination,
    --             })
    --             vim.notify(
    --                 "[simaxme-java] Neo-tree file moved: " .. data.source .. ", to " .. data.destination,
    --                 vim.log.levels.INFO
    --             )
    --         end,
    --     })
    -- end

    vim.notify("[simaxme-java] Neo-tree integration enabled", vim.log.levels.INFO)
end

return neoTreeIntegration
