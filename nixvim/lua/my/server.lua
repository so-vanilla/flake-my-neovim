local M = {}

local function runtime_dir()
	return vim.env.XDG_RUNTIME_DIR or "/tmp"
end

function M.path()
	local user = vim.env.USER or "user"
	return vim.env.MY_NEOVIM_SERVER or (runtime_dir() .. "/my-neovim-" .. user .. "/special-edit.sock")
end

function M.start()
	local path = M.path()
	vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")

	for _, server in ipairs(vim.fn.serverlist()) do
		if server == path then
			vim.g.my_neovim_server = path
			return path
		end
	end

	local ok, result = pcall(vim.fn.serverstart, path)
	if not ok then
		vim.notify("Neovim RPC server start failed: " .. tostring(result), vim.log.levels.WARN)
		return nil
	end

	vim.g.my_neovim_server = result
	return result
end

return M
