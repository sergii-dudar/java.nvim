local neoTreeIntegration = {}

local utils = require("simaxme-java.rename.utils")
local options = require("simaxme-java.options")

-- Initialize Neo-tree integration:
-- Subscribes to "file_renamed" and "file_moved" events
function neoTreeIntegration.setup()
	local ok, events = pcall(require, "neo-tree.events")
	if not ok then
		vim.notify("[simaxme-java] Neo-tree not found", vim.log.levels.WARN)
		return
	end

	local java_rename = require("simaxme-java.rename")

	-- helper to process rename/move events
	local function handle_rename_or_move(old_path, new_path)
		local regex = "%.java$"
		local is_java_file = string.find(old_path, regex) ~= nil and string.find(new_path, regex) ~= nil

		if not is_java_file then
			local root_markers = options.get_java_options().root_markers
			local parts = utils.split_with_patterns(old_path, root_markers)

			if #parts <= 1 then
				return
			end
		end

		java_rename.on_rename_file(old_path, utils.realpath(new_path))
	end

	-- Neo-tree emits events via its `events` module
	events.subscribe({
		event = events.FILE_RENAMED,
		handler = function(data)
			handle_rename_or_move(data.source, data.destination)
			vim.notify("[simaxme-java] Neo-tree file renamed", vim.log.levels.INFO)
		end,
	})

	-- Neo-tree 3.x and newer emits separate move events (rename covers both, but just in case)
	if events.FILE_MOVED then
		events.subscribe({
			event = events.FILE_MOVED,
			handler = function(data)
				handle_rename_or_move(data.source, data.destination)
				vim.notify("[simaxme-java] Neo-tree file moved", vim.log.levels.INFO)
			end,
		})
	end

	vim.notify("[simaxme-java] Neo-tree integration enabled", vim.log.levels.INFO)
end

return neoTreeIntegration
