local M = {}

local function termcodes(keys)
	return vim.api.nvim_replace_termcodes(keys, true, false, true)
end

local function feed(keys, mode)
	vim.api.nvim_feedkeys(termcodes(keys), mode or "n", false)
end

function M.keyboard_quit()
	pcall(vim.cmd.nohlsearch)

	local ok, cmp = pcall(require, "blink.cmp")
	if ok and cmp.is_visible and cmp.is_visible() then
		pcall(cmp.cancel)
	end
end

function M.move_beginning_of_line()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()
	local first_nonblank = line:find("%S")
	local target = first_nonblank and (first_nonblank - 1) or #line

	if col == target then
		target = 0
	end

	vim.api.nvim_win_set_cursor(0, { row, target })
end

local function diagnostic_jump(count)
	if vim.diagnostic.jump then
		vim.diagnostic.jump({
			count = count,
			float = true,
		})
	elseif count > 0 then
		vim.diagnostic.goto_next({ float = true })
	else
		vim.diagnostic.goto_prev({ float = true })
	end
end

function M.next_diagnostic()
	diagnostic_jump(1)
end

function M.prev_diagnostic()
	diagnostic_jump(-1)
end

function M.yank()
	feed("<C-r>+", "n")
end

return M
