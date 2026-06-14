local M = {}

local function current_file()
	local name = vim.api.nvim_buf_get_name(0)
	if name == "" or vim.bo.buftype ~= "" then
		vim.notify("Buffer replace is only enabled for file buffers", vim.log.levels.WARN, {
			title = "replace",
		})
		return nil
	end
	return name
end

local function grug(opts)
	require("grug-far").open(vim.tbl_deep_extend("force", {
		transient = false,
	}, opts or {}))
end

local function prefills(path, literal)
	return {
		paths = path,
		flags = literal and "--fixed-strings" or nil,
	}
end

function M.buffer_literal()
	local path = current_file()
	if not path then
		return
	end
	grug({
		prefills = prefills(path, true),
	})
end

function M.buffer_regexp()
	local path = current_file()
	if not path then
		return
	end
	grug({
		prefills = prefills(path, false),
	})
end

function M.project_literal()
	grug({
		prefills = prefills(require("my.project").root(), true),
	})
end

function M.project_regexp()
	grug({
		prefills = prefills(require("my.project").root(), false),
	})
end

function M.visual_within_literal()
	grug({
		visualSelectionUsage = "operate-within-range",
		prefills = prefills(nil, true),
	})
end

function M.visual_within_regexp()
	grug({
		visualSelectionUsage = "operate-within-range",
		prefills = prefills(nil, false),
	})
end

return M
