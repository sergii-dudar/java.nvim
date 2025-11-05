local java = {}

local options = require("simaxme-java.options")
local rename = require("simaxme-java.rename")
local snippets = require("simaxme-java.snippets")

---@param opts {
---     rename: {
---     enable: boolean,
---     nvimtree: boolean,
---     neotree: boolean,
---     oilnvim: boolean,
---     write_and_close: boolean },
---     snippets: any}
function java.setup(opts)
    if opts == nil then
        opts = {}
    end

    options.setup(opts)
    rename.setup(opts.rename)
    snippets.setup(opts.snippets)
end

java.snacks = {}
java.snacks.rename_current = require("simaxme-java.rename.snacks-nvim").rename_current

return java
