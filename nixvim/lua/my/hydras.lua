local M = {}

local initialized = false
local hydras = {}
local restore_insert_after_head = false

local function was_insert()
	return vim.api.nvim_get_mode().mode:match("^[iR]") ~= nil
end

local function restore_insert()
	if restore_insert_after_head then
		require("my.editor").start_insert_if_editable()
	end
end

local function protected(fn, title)
	return function()
		local ok, err = pcall(fn)
		if not ok then
			vim.notify(err, vim.log.levels.ERROR, { title = title or "hydra" })
		end
		restore_insert()
	end
end

local function activate(name, return_to_insert)
	if return_to_insert ~= nil then
		restore_insert_after_head = return_to_insert
	else
		restore_insert_after_head = was_insert()
	end
	hydras[name]:activate()
	restore_insert()
end

local function undo()
	vim.cmd.undo()
end

local function redo()
	vim.cmd.redo()
end

local function setup_undo(Hydra)
	hydras.undo = Hydra({
		name = "Undo",
		mode = { "n", "i" },
		hint = [[
^Undo^
^-----------^
_u_: undo
_r_: redo
_<C-g>_: quit
_q_: quit
]],
		config = {
			color = "pink",
			hint = {
				type = "window",
				position = "bottom",
			},
		},
		heads = {
			{ "u", protected(undo, "undo"), { desc = "undo" } },
			{ "r", protected(redo, "undo"), { desc = "redo" } },
			{ "<C-g>", nil, { exit = true, desc = "exit" } },
			{ "<CR>", nil, { exit = true, desc = "exit" } },
			{ "q", nil, { exit = true, desc = "exit" } },
		},
	})
end

local function setup_kmacro(Hydra)
	local macro = require("my.macro")

	hydras.kmacro = Hydra({
		name = "Kmacro",
		mode = { "n", "i" },
		hint = [[
^Repeat^
^--------------^
_e_: call macro
_<C-g>_: quit
_q_: quit
]],
		config = {
			color = "pink",
			hint = {
				type = "window",
				position = "bottom",
			},
		},
		heads = {
			{ "e", protected(macro.call, "macro"), { desc = "call macro" } },
			{ "<C-g>", nil, { exit = true, desc = "exit" } },
			{ "<CR>", nil, { exit = true, desc = "exit" } },
			{ "q", nil, { exit = true, desc = "exit" } },
		},
	})
end

local function setup_softpair(Hydra)
	local ok, softpair = pcall(require, "softpair")
	if not ok then
		return
	end

	hydras.softpair = Hydra({
		name = "Softpair",
		mode = { "n", "i" },
		hint = [[
^Edit^             ^Move^
^---------------------------------^
_<C-w>_: squeeze   _]_: slurp forward
_s_: splice        _}_: barf forward
^ ^                _[_: slurp backward
^ ^                _{_: barf backward
_<C-g>_: quit
_q_: quit
]],
		config = {
			color = "pink",
			hint = {
				type = "window",
				position = "bottom",
			},
		},
		heads = {
			{ "<C-w>", protected(softpair.squeeze, "softpair"), { desc = "squeeze" } },
			{ "s", protected(softpair.splice, "softpair"), { desc = "splice" } },
			{ "]", protected(softpair.slurp_forward, "softpair"), { desc = "slurp forward" } },
			{ "}", protected(softpair.barf_forward, "softpair"), { desc = "barf forward" } },
			{ "[", protected(softpair.slurp_backward, "softpair"), { desc = "slurp backward" } },
			{ "{", protected(softpair.barf_backward, "softpair"), { desc = "barf backward" } },
			{ "<C-g>", nil, { exit = true, desc = "exit" } },
			{ "<CR>", nil, { exit = true, desc = "exit" } },
			{ "q", nil, { exit = true, desc = "exit" } },
		},
	})
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

local function setup_conflict(Hydra)
	local ok, git_conflict = pcall(require, "git-conflict")
	if not ok then
		return
	end

	hydras.conflict = Hydra({
		name = "Git conflict",
		mode = { "n", "i" },
		hint = [[
^Move^       ^Keep^                 ^All^
^------------------------------------------------^
_n_: next    _u_: ours/current      _U_: ours all
_p_: prev    _l_: theirs/incoming   _L_: theirs all
^ ^          _b_: base              _B_: base all
^ ^          _a_: both              _A_: both all
^ ^          _0_: none              _N_: none all
^ ^                                  _<C-g>_: quit
^ ^                                  _q_: quit
]],
		config = {
			color = "pink",
			hint = {
				type = "window",
				position = "bottom",
			},
		},
		heads = {
			{ "n", protected(function()
				git_conflict.find_next("ours")
			end, "git-conflict"), { desc = "next" } },
			{
				"p",
				protected(function()
					git_conflict.find_prev("ours")
				end, "git-conflict"),
				{
					desc = "previous",
				},
			},
			{
				"u",
				protected(function()
					git_conflict.choose("ours")
				end, "git-conflict"),
				{
					desc = "ours/current",
				},
			},
			{
				"l",
				protected(function()
					git_conflict.choose("theirs")
				end, "git-conflict"),
				{ desc = "theirs/incoming" },
			},
			{ "b", protected(function()
				git_conflict.choose("base")
			end, "git-conflict"), { desc = "base" } },
			{ "a", protected(function()
				git_conflict.choose("both")
			end, "git-conflict"), { desc = "both" } },
			{ "0", protected(function()
				git_conflict.choose("none")
			end, "git-conflict"), { desc = "none" } },
			{
				"U",
				protected(function()
					choose_all("ours")
				end, "git-conflict"),
				{
					exit = true,
					desc = "ours all",
				},
			},
			{
				"L",
				protected(function()
					choose_all("theirs")
				end, "git-conflict"),
				{ exit = true, desc = "theirs all" },
			},
			{
				"B",
				protected(function()
					choose_all("base")
				end, "git-conflict"),
				{ exit = true, desc = "base all" },
			},
			{
				"A",
				protected(function()
					choose_all("both")
				end, "git-conflict"),
				{ exit = true, desc = "both all" },
			},
			{
				"N",
				protected(function()
					choose_all("none")
				end, "git-conflict"),
				{ exit = true, desc = "none all" },
			},
			{ "<C-g>", nil, { exit = true, desc = "exit" } },
			{ "<CR>", nil, { exit = true, desc = "exit" } },
			{ "q", nil, { exit = true, desc = "exit" } },
		},
	})
end

local function setup_window(Hydra)
	local function wincmd(cmd)
		return function()
			vim.cmd("wincmd " .. cmd)
		end
	end

	hydras.window = Hydra({
		name = "Window",
		mode = { "n", "i" },
		hint = [[
^Move^            ^Split^                  ^Resize^
^---------------------------------------------------------^
_h_: left         _2_: split below         _H_: width -
_j_: down         _3_: split right         _L_: width +
_k_: up           _0_: close               _J_: height -
_l_: right        _o_: next                _K_: height +
_p_: previous     _=_: balance             _q_: quit
^ ^               ^ ^                      _<C-g>_: quit
]],
		config = {
			color = "pink",
			hint = {
				type = "window",
				position = "bottom",
			},
		},
		heads = {
			{ "h", protected(wincmd("h"), "window"), { desc = "left" } },
			{ "j", protected(wincmd("j"), "window"), { desc = "down" } },
			{ "k", protected(wincmd("k"), "window"), { desc = "up" } },
			{ "l", protected(wincmd("l"), "window"), { desc = "right" } },
			{ "o", protected(wincmd("w"), "window"), { desc = "next" } },
			{ "p", protected(wincmd("W"), "window"), { desc = "previous" } },
			{ "2", protected(function()
				vim.cmd.split()
			end, "window"), { desc = "split below" } },
			{ "3", protected(function()
				vim.cmd.vsplit()
			end, "window"), { desc = "split right" } },
			{ "0", protected(function()
				vim.cmd.close()
			end, "window"), { desc = "close" } },
			{ "=", protected(wincmd("="), "window"), { desc = "balance" } },
			{ "H", protected(wincmd("5<"), "window"), { desc = "width -" } },
			{ "L", protected(wincmd("5>"), "window"), { desc = "width +" } },
			{ "J", protected(wincmd("3-"), "window"), { desc = "height -" } },
			{ "K", protected(wincmd("3+"), "window"), { desc = "height +" } },
			{ "<C-g>", nil, { exit = true, desc = "exit" } },
			{ "<CR>", nil, { exit = true, desc = "exit" } },
			{ "q", nil, { exit = true, desc = "exit" } },
		},
	})
end

function M.setup()
	if initialized then
		return
	end

	local Hydra = require("hydra")
	setup_undo(Hydra)
	setup_kmacro(Hydra)
	setup_softpair(Hydra)
	setup_conflict(Hydra)
	setup_window(Hydra)
	initialized = true
end

function M.undo_then()
	local return_to_insert = was_insert()
	protected(undo, "undo")()
	activate("undo", return_to_insert)
end

function M.redo_then()
	local return_to_insert = was_insert()
	protected(redo, "undo")()
	activate("undo", return_to_insert)
end

function M.macro_end_and_call()
	local return_to_insert = was_insert()
	require("my.macro").end_and_call()
	activate("kmacro", return_to_insert)
end

function M.softpair()
	if hydras.softpair then
		activate("softpair", was_insert())
	end
end

function M.conflict()
	if hydras.conflict then
		activate("conflict", was_insert())
	end
end

function M.window()
	if hydras.window then
		activate("window", was_insert())
	end
end

return M
