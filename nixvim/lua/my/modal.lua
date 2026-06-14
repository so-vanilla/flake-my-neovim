local M = {}

local restore_insert_after_head = false
local active_layer = nil
local modal_generation = 0
local pending_generation = nil

local function termcodes(keys)
	return vim.api.nvim_replace_termcodes(keys, true, false, true)
end

local function was_insert()
	return vim.api.nvim_get_mode().mode:match("^[iR]") ~= nil
end

local function restore_insert()
	if restore_insert_after_head then
		require("my.editor").start_insert_if_editable()
	end
end

local function close_active_layer()
	if not active_layer then
		return
	end

	if active_layer.layer and active_layer.layer:is_active() then
		active_layer.layer:exit()
	end
	if active_layer.close_hint then
		active_layer.close_hint()
	end
	active_layer = nil
end

local function cancel_pending_activation()
	if pending_generation then
		modal_generation = modal_generation + 1
		pending_generation = nil
	end
end

local function protected(fn, title, exit_after)
	return function()
		local ok, err = pcall(fn)
		if not ok then
			vim.notify(err, vim.log.levels.ERROR, { title = title or "modal" })
		end
		if exit_after then
			M.exit()
		else
			restore_insert()
		end
	end
end

local function line_width(lines)
	local width = 1
	for _, line in ipairs(lines) do
		width = math.max(width, vim.fn.strdisplaywidth(line))
	end
	return width
end

local function show_hint(lines)
	if #vim.api.nvim_list_uis() == 0 then
		return function() end
	end

	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.bo[bufnr].buftype = "nofile"
	vim.bo[bufnr].bufhidden = "wipe"
	vim.bo[bufnr].swapfile = false
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

	local width = math.min(math.max(line_width(lines), 24), math.max(vim.o.columns - 4, 24))
	local height = #lines
	local row = math.max(vim.o.lines - height - 3, 0)
	local col = math.max(math.floor((vim.o.columns - width) / 2), 0)
	local ok, winid = pcall(vim.api.nvim_open_win, bufnr, false, {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = height,
		style = "minimal",
		border = "single",
		focusable = false,
		zindex = 60,
	})

	if not ok then
		pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
		return function() end
	end

	return function()
		if vim.api.nvim_win_is_valid(winid) then
			pcall(vim.api.nvim_win_close, winid, true)
		elseif vim.api.nvim_buf_is_valid(bufnr) then
			pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
		end
	end
end

local function enter(name, hint, mappings, return_to_insert)
	modal_generation = modal_generation + 1
	local generation = modal_generation
	pending_generation = nil

	if return_to_insert ~= nil then
		restore_insert_after_head = return_to_insert
	else
		restore_insert_after_head = was_insert()
	end

	local layer_was_active = active_layer ~= nil
	close_active_layer()

	local function activate()
		if generation ~= modal_generation then
			return
		end
		pending_generation = nil

		local close_hint = show_hint(hint)
		local layer_maps = {
			i = {},
			n = {},
		}

		for lhs, rhs in pairs(mappings) do
			local map_lhs = termcodes(lhs)
			for mode, maps in pairs(layer_maps) do
				maps[map_lhs] = {
					rhs = rhs,
					desc = name,
					noremap = true,
					nowait = true,
					silent = true,
				}
			end
		end

		local ok, layer_or_err = pcall(function()
			local layer = require("libmodal").layer.new(layer_maps)
			layer:enter()
			return layer
		end)
		if ok then
			active_layer = {
				layer = layer_or_err,
				close_hint = close_hint,
				generation = generation,
			}
		else
			close_hint()
			local err = layer_or_err
			vim.notify(err, vim.log.levels.ERROR, { title = name })
		end
		restore_insert()
	end

	if layer_was_active then
		pending_generation = generation
		vim.schedule(activate)
	else
		activate()
	end
end

local function exit()
	cancel_pending_activation()
	close_active_layer()
	restore_insert()
end

local function undo()
	vim.cmd.undo()
end

local function redo()
	vim.cmd.redo()
end

local function choose_all(side)
	local git_conflict = require("git-conflict")
	local bufnr = vim.api.nvim_get_current_buf()
	local count = git_conflict.conflict_count(bufnr)
	if count == 0 then
		vim.notify("No conflicts in this buffer", vim.log.levels.INFO, { title = "git-conflict" })
		return
	end

	vim.api.nvim_win_set_cursor(0, { 1, 0 })
	for _ = 1, count do
		pcall(git_conflict.find_next, "ours")
		local before = git_conflict.conflict_count(bufnr)
		if before == 0 then
			break
		end
		git_conflict.choose(side)
		if git_conflict.conflict_count(bufnr) >= before then
			break
		end
	end
end

local function wincmd(cmd)
	return function()
		vim.cmd("wincmd " .. cmd)
	end
end

function M.setup() end

function M.undo_then()
	local return_to_insert = was_insert()
	protected(undo, "undo")()
	enter("UNDO", {
		"Undo",
		"u: undo    r: redo",
		"C-g/q/CR: quit",
	}, {
		u = protected(undo, "undo"),
		r = protected(redo, "undo"),
		["<CR>"] = exit,
		q = exit,
	}, return_to_insert)
end

function M.redo_then()
	local return_to_insert = was_insert()
	protected(redo, "undo")()
	enter("UNDO", {
		"Undo",
		"u: undo    r: redo",
		"C-g/q/CR: quit",
	}, {
		u = protected(undo, "undo"),
		r = protected(redo, "undo"),
		["<CR>"] = exit,
		q = exit,
	}, return_to_insert)
end

function M.macro_end_and_call()
	local return_to_insert = was_insert()
	require("my.macro").end_and_call()
	local macro = require("my.macro")
	enter("KMACRO", {
		"Kmacro",
		"e: call macro",
		"C-g/q/CR: quit",
	}, {
		e = protected(macro.call, "macro"),
		["<CR>"] = exit,
		q = exit,
	}, return_to_insert)
end

function M.softpair()
	local ok_special, special_ui = pcall(require, "my.special_ui")
	if ok_special and special_ui.is_special() then
		return
	end

	local ok, softpair = pcall(require, "softpair")
	if not ok then
		return
	end

	enter("SOFTPAIR", {
		"Softpair",
		"C-w: squeeze   s: splice",
		"]: slurp forward    }: barf forward",
		"[: slurp backward   {: barf backward",
		"C-g/q/CR: quit",
	}, {
		["<C-w>"] = protected(softpair.squeeze, "softpair"),
		s = protected(softpair.splice, "softpair"),
		["]"] = protected(softpair.slurp_forward, "softpair"),
		["}"] = protected(softpair.barf_forward, "softpair"),
		["["] = protected(softpair.slurp_backward, "softpair"),
		["{"] = protected(softpair.barf_backward, "softpair"),
		["<CR>"] = exit,
		q = exit,
	}, was_insert())
end

function M.conflict()
	local ok, git_conflict = pcall(require, "git-conflict")
	if not ok then
		return
	end

	enter("CONFLICT", {
		"Git conflict",
		"n/p: next/prev",
		"u/l/b/a/0: ours/theirs/base/both/none",
		"U/L/B/A/N: choose all",
		"C-g/q/CR: quit",
	}, {
		n = protected(function()
			git_conflict.find_next("ours")
		end, "git-conflict"),
		p = protected(function()
			git_conflict.find_prev("ours")
		end, "git-conflict"),
		u = protected(function()
			git_conflict.choose("ours")
		end, "git-conflict"),
		l = protected(function()
			git_conflict.choose("theirs")
		end, "git-conflict"),
		b = protected(function()
			git_conflict.choose("base")
		end, "git-conflict"),
		a = protected(function()
			git_conflict.choose("both")
		end, "git-conflict"),
		["0"] = protected(function()
			git_conflict.choose("none")
		end, "git-conflict"),
		U = protected(function()
			choose_all("ours")
		end, "git-conflict", true),
		L = protected(function()
			choose_all("theirs")
		end, "git-conflict", true),
		B = protected(function()
			choose_all("base")
		end, "git-conflict", true),
		A = protected(function()
			choose_all("both")
		end, "git-conflict", true),
		N = protected(function()
			choose_all("none")
		end, "git-conflict", true),
		["<CR>"] = exit,
		q = exit,
	}, was_insert())
end

function M.window()
	enter("WINDOW", {
		"Window",
		"h/j/k/l: move    o/p: next/previous",
		"2/3: split       0: close",
		"= balance        H/L/J/K: resize",
		"C-g/q/CR: quit",
	}, {
		h = protected(wincmd("h"), "window"),
		j = protected(wincmd("j"), "window"),
		k = protected(wincmd("k"), "window"),
		l = protected(wincmd("l"), "window"),
		o = protected(wincmd("w"), "window"),
		p = protected(wincmd("W"), "window"),
		["2"] = protected(function()
			vim.cmd.split()
		end, "window"),
		["3"] = protected(function()
			vim.cmd.vsplit()
		end, "window"),
		["0"] = protected(function()
			vim.cmd.close()
		end, "window"),
		["="] = protected(wincmd("="), "window"),
		H = protected(wincmd("5<"), "window"),
		L = protected(wincmd("5>"), "window"),
		J = protected(wincmd("3-"), "window"),
		K = protected(wincmd("3+"), "window"),
		["<CR>"] = exit,
		q = exit,
	}, was_insert())
end

function M.exit()
	exit()
end

function M.is_active()
	return active_layer ~= nil or pending_generation ~= nil
end

return M
