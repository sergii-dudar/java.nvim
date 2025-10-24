local nvimTreeIntegration = {}

-- initialise nvim tree integration
-- will automaticly subscribe to the NodeRenamed event and execute the on_rename_file method
function nvimTreeIntegration.setup()
    local status, api = pcall(require, "nvim-tree.api")

    if not status then
        return
    end

    local rename_utils = require("simaxme-java.rename.rename-utils")
    api.events.subscribe(api.events.Event.NodeRenamed, rename_utils.make_rename)

    vim.notify("[simaxme-java] Nvim-tree initiated: ", vim.log.levels.INFO)
end

return nvimTreeIntegration
