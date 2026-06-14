local M = {}

local blocked_keys = {
	{ modes = { "n", "i" }, lhs = "<C-s>" },
	{ modes = { "n", "i", "x" }, lhs = "<C-M-s>" },
	{ modes = { "n", "i", "x" }, lhs = "<M-%>" },
	{ modes = { "n", "i", "x" }, lhs = "<C-M-%>" },
	{ modes = { "n", "i" }, lhs = "<M-x>" },
	{ modes = { "n", "i", "x" }, lhs = "<C-x>", nowait = true },
	{ modes = { "n", "i", "x" }, lhs = "<C-c>", nowait = true },
	{ modes = { "n", "i", "x" }, lhs = "<F1>", nowait = true },
}

local function has_buffer_map(mode, lhs)
	local map = vim.fn.maparg(lhs, mode, false, true)
	return type(map) == "table" and map.buffer == 1
end

function M.disable_emacs_keys()
	local bufnr = vim.api.nvim_get_current_buf()

	for _, key in ipairs(blocked_keys) do
		for _, mode in ipairs(key.modes) do
			if not has_buffer_map(mode, key.lhs) then
				vim.keymap.set(mode, key.lhs, "<Nop>", {
					buffer = bufnr,
					desc = "Disabled in special UI",
					noremap = true,
					nowait = key.nowait or false,
					silent = true,
				})
			end
		end
	end
end

return M
