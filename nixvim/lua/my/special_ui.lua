local M = {}

M.filetypes = {
	fzf = true,
	["grug-far"] = true,
	help = true,
	man = true,
	NeogitStatus = true,
	oil = true,
	OverseerForm = true,
	OverseerList = true,
	OverseerOutput = true,
	OverseerTask = true,
	qf = true,
}

M.buftypes = {
	nofile = true,
	prompt = true,
	quickfix = true,
	terminal = true,
}

function M.is_special(bufnr)
	bufnr = bufnr or 0
	return M.filetypes[vim.bo[bufnr].filetype] == true or M.buftypes[vim.bo[bufnr].buftype] == true
end

return M
