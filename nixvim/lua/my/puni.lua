local M = {}

local delimiters = {
	["("] = ")",
	["["] = "]",
	["{"] = "}",
}

local closing = {}
for open, close in pairs(delimiters) do
	closing[close] = open
end

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, { title = "puni" })
end

local function set_register(text)
	local regtype = text:find("\n", 1, true) and "V" or "v"
	vim.fn.setreg('"', text, regtype)
	if vim.o.clipboard:find("unnamedplus", 1, true) then
		pcall(vim.fn.setreg, "+", text, regtype)
	end
end

local function text_from_lines(lines)
	return table.concat(lines, "\n")
end

local function range_text(bufnr, range)
	return vim.api.nvim_buf_get_text(bufnr, range[1], range[2], range[3], range[4], {})
end

local function balanced_fragment(text)
	local stack = {}
	for char in text:gmatch(".") do
		if delimiters[char] then
			table.insert(stack, char)
		elseif closing[char] then
			if stack[#stack] ~= closing[char] then
				return false
			end
			table.remove(stack)
		end
	end

	return #stack == 0
end

local function kill_range()
	local bufnr = vim.api.nvim_get_current_buf()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line_count = vim.api.nvim_buf_line_count(bufnr)
	local line = vim.api.nvim_get_current_line()

	if col < #line then
		local lines = vim.api.nvim_buf_get_text(bufnr, row - 1, col, row - 1, #line, {})
		return {
			bufnr = bufnr,
			start_row = row - 1,
			start_col = col,
			end_row = row - 1,
			end_col = #line,
			text = text_from_lines(lines),
		}
	end

	if row < line_count then
		return {
			bufnr = bufnr,
			start_row = row - 1,
			start_col = #line,
			end_row = row,
			end_col = 0,
			text = "\n",
		}
	end
end

function M.kill_line()
	local target = kill_range()
	if not target or target.text == "" then
		return
	end

	if not balanced_fragment(target.text) then
		notify("Refusing to kill line: deletion would remove unmatched delimiter", vim.log.levels.WARN)
		return
	end

	set_register(target.text)
	vim.api.nvim_buf_set_text(target.bufnr, target.start_row, target.start_col, target.end_row, target.end_col, {})
end

function M.squeeze()
	local ok, selections = pcall(require, "nvim-paredit.api.selections")
	if not ok then
		notify("nvim-paredit selections API is unavailable", vim.log.levels.WARN)
		return
	end

	local inside_ok, inside = pcall(selections.get_range_in_form)
	local around_ok, around = pcall(selections.get_range_around_form)
	if not inside_ok or not around_ok then
		notify("No surrounding form to squeeze", vim.log.levels.WARN)
		return
	end

	if not inside or not around then
		notify("No surrounding form to squeeze", vim.log.levels.WARN)
		return
	end

	local bufnr = vim.api.nvim_get_current_buf()
	set_register(text_from_lines(range_text(bufnr, inside)))
	vim.api.nvim_buf_set_text(bufnr, around[1], around[2], around[3], around[4], {})
end

return M
