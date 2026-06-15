local M = {}

local root = require("my.root")

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, { title = "project" })
end

local function current_path()
	return root.current_path()
end

function M.root(path)
	return root.root(path)
end

local function has_git(root)
	return vim.fn.isdirectory(root .. "/.git") == 1 or vim.fn.filereadable(root .. "/.git") == 1
end

local function add_root(roots, seen, root)
	if root and root ~= "" and not seen[root] and vim.fn.isdirectory(root) == 1 then
		seen[root] = true
		table.insert(roots, root)
	end
end

function M.files()
	local root = M.root()
	local fzf = require("fzf-lua")
	if has_git(root) then
		fzf.git_files({ cwd = root })
	else
		fzf.files({ cwd = root })
	end
end

function M.grep()
	require("fzf-lua").live_grep({ cwd = M.root() })
end

function M.buffers()
	require("fzf-lua").buffers({ cwd = M.root() })
end

local function known_roots()
	local roots = {}
	local seen = {}

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		local name = vim.api.nvim_buf_get_name(bufnr)
		if name ~= "" then
			add_root(roots, seen, M.root(name))
		end
	end

	local ok, project = pcall(require, "project")
	if ok and project.get_recent_projects then
		local recent_ok, recent = pcall(project.get_recent_projects, true, false)
		if recent_ok then
			for _, root in ipairs(recent) do
				add_root(roots, seen, root)
			end
		end
	end

	table.sort(roots)
	return roots
end

function M.switch()
	local roots = known_roots()
	if #roots == 0 then
		notify("No known project roots", vim.log.levels.WARN)
		return
	end

	require("fzf-lua").fzf_exec(roots, {
		prompt = "Project> ",
		actions = {
			["default"] = function(selected)
				local root = selected[1]
				if root and root ~= "" then
					vim.cmd("lcd " .. vim.fn.fnameescape(root))
					require("fzf-lua").files({ cwd = root })
				end
			end,
		},
	})
end

local function open_oil(path)
	require("my.editor").stop_insert()
	require("oil").open(vim.fn.expand(path))
end

local function trailing_slash(path)
	if path:sub(-1) == "/" then
		return path
	end
	return path .. "/"
end

function M.find_file_input()
	vim.ui.input({
		prompt = "Find file> ",
		default = trailing_slash(vim.fn.fnamemodify(M.root(), ":p")),
		completion = "file",
	}, function(input)
		if input == nil or input == "" then
			return
		end

		local path = vim.fn.expand(input)
		if vim.fn.isdirectory(path) == 1 then
			open_oil(path)
			return
		end

		vim.cmd.edit(vim.fn.fnameescape(path))
	end)
end

function M.oil_root()
	open_oil(M.root())
end

function M.oil_current()
	local path = current_path()
	local dir = vim.fn.isdirectory(path) == 1 and path or vim.fn.fnamemodify(path, ":p:h")
	open_oil(dir)
end

function M.oil_prompt()
	vim.ui.input({
		prompt = "Oil directory> ",
		default = M.root(),
		completion = "dir",
	}, function(input)
		if input and input ~= "" then
			open_oil(input)
		end
	end)
end

function M.neogit()
	require("my.editor").stop_insert()
	vim.cmd("Neogit cwd=" .. vim.fn.fnameescape(M.root()))
end

return M
