local M = {}

local function termcodes(keys)
	return vim.api.nvim_replace_termcodes(keys, true, false, true)
end

local function feed(keys)
	vim.api.nvim_feedkeys(termcodes(keys), "nx", false)
end

local function was_insert()
	return vim.api.nvim_get_mode().mode:match("^[iR]") ~= nil
end

local function restore_insert()
	vim.schedule(function()
		if vim.api.nvim_get_mode().mode:match("^n") then
			vim.cmd.startinsert()
		end
	end)
end

function M.comment_current()
	local return_to_insert = was_insert()
	if return_to_insert then
		vim.cmd.stopinsert()
	end

	require("Comment.api").toggle.linewise.current()

	if return_to_insert then
		restore_insert()
	end
end

function M.comment_visual()
	local api = require("Comment.api")
	feed("<Esc>")
	api.toggle.linewise(vim.fn.visualmode())
end

function M.select_all()
	if was_insert() then
		feed("<Esc>ggVG")
	else
		feed("ggVG")
	end
end

function M.select_paragraph()
	if was_insert() then
		feed("<Esc>vip")
	else
		feed("vip")
	end
end

function M.exchange_mark()
	local mode = vim.api.nvim_get_mode().mode
	if mode:match("^[vV\22]") then
		feed("o")
	elseif mode:match("^[iR]") then
		feed("<Esc>gv")
	else
		feed("gv")
	end
end

return M
