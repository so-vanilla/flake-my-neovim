local M = {}

local state = {
	last_pane_id = nil,
}

local function wezterm_bin()
	return vim.env.WEZTERM_BIN or "wezterm"
end

local function notify_error(message)
	vim.notify(message, vim.log.levels.ERROR, { title = "special-edit" })
end

local function buffer_text(bufnr)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	return table.concat(lines, "\n")
end

local function send_text(pane_id, text)
	if not pane_id or pane_id == "" then
		notify_error("missing target pane id")
		return false
	end

	local ok, output = pcall(vim.fn.system, {
		wezterm_bin(),
		"cli",
		"send-text",
		"--pane-id",
		tostring(pane_id),
	}, text)

	if not ok then
		notify_error(("wezterm cli send-text failed: %s"):format(output))
		return false
	end

	if vim.v.shell_error ~= 0 then
		notify_error(("wezterm cli send-text failed: %s"):format(output))
		return false
	end

	return true
end

local function close_special_buffer(bufnr)
	for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
		if vim.api.nvim_win_is_valid(win) then
			pcall(vim.api.nvim_win_close, win, true)
		end
	end

	if vim.api.nvim_buf_is_valid(bufnr) then
		vim.api.nvim_buf_delete(bufnr, { force = true })
	end
end

local function heredoc_delimiter(text)
	local seed = vim.fn.sha256(text .. tostring(vim.uv.hrtime())):sub(1, 16)
	local delimiter = "__NVIM_SPECIAL_EDIT_" .. seed .. "__"
	local suffix = 0

	while text:find("\n" .. delimiter .. "\n", 1, true) or text == delimiter do
		suffix = suffix + 1
		delimiter = "__NVIM_SPECIAL_EDIT_" .. seed .. "_" .. tostring(suffix) .. "__"
	end

	return delimiter
end

local function shell_script_payload(text)
	local delimiter = heredoc_delimiter(text)
	return table.concat({
		[[(]],
		[[tmp=$(mktemp "${TMPDIR:-/tmp}/nvim-special-edit.XXXXXX.sh") || exit]],
		[[trap 'rm -f "$tmp"' EXIT]],
		[[cat > "$tmp" <<']] .. delimiter .. [[']],
		text,
		delimiter,
		[[${SHELL:-sh} "$tmp"]],
		[[)]],
	}, "\n")
end

local function submit(bufnr, opts)
	opts = opts or {}
	local pane_id = vim.b[bufnr].special_edit_pane_id or state.last_pane_id
	local text = buffer_text(bufnr)

	if opts.script then
		text = shell_script_payload(text) .. "\r"
	elseif opts.enter then
		text = text .. "\r"
	end

	if send_text(pane_id, text) then
		close_special_buffer(bufnr)
	end
end

local function set_buffer_maps(bufnr)
	local map = function(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, {
			buffer = bufnr,
			nowait = true,
			silent = true,
			desc = desc,
		})
	end

	map({ "n", "i" }, "<C-c><C-c>", function()
		submit(bufnr, { enter = true })
	end, "Send and press Enter")

	map({ "n", "i" }, "<C-c>'", function()
		submit(bufnr)
	end, "Paste without Enter")

	map({ "n", "i" }, "<C-c><C-s>", function()
		submit(bufnr, { script = true })
	end, "Run as shell script")

	map({ "n", "i" }, "<C-c><C-k>", function()
		close_special_buffer(bufnr)
	end, "Cancel special edit")
end

local function focus_buffer(bufnr)
	local wins = vim.fn.win_findbuf(bufnr)
	if #wins > 0 and vim.api.nvim_win_is_valid(wins[1]) then
		vim.api.nvim_set_current_win(wins[1])
	else
		vim.cmd("botright split")
		vim.api.nvim_win_set_buf(0, bufnr)
		vim.api.nvim_win_set_height(0, math.max(8, math.floor(vim.o.lines * 0.35)))
	end
	vim.cmd.startinsert()
end

local function existing_buffer(name)
	local bufnr = vim.fn.bufnr(name)
	if bufnr > 0 and vim.api.nvim_buf_is_valid(bufnr) then
		return bufnr
	end
end

function M.open(args)
	args = args or {}
	local pane_id = args.pane_id

	if not pane_id then
		notify_error("missing target pane id")
		return "missing pane id"
	end

	state.last_pane_id = pane_id

	local nvim_pane_id = vim.env.WEZTERM_PANE
	local name = ("special-edit://wezterm-pane/%s"):format(pane_id)
	local existing = existing_buffer(name)
	if existing then
		focus_buffer(existing)
		return nvim_pane_id or "ok"
	end

	local bufnr = vim.api.nvim_create_buf(false, true)
	local ok, err = pcall(vim.api.nvim_buf_set_name, bufnr, name)
	if not ok then
		close_special_buffer(bufnr)
		notify_error(tostring(err))
		return "failed"
	end

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
		"",
	})
	vim.bo[bufnr].buftype = "nofile"
	vim.bo[bufnr].bufhidden = "wipe"
	vim.bo[bufnr].swapfile = false
	vim.bo[bufnr].filetype = args.filetype or "special-edit"
	vim.b[bufnr].completion = false
	vim.b[bufnr].softpair_enabled = false
	vim.b[bufnr].special_edit_pane_id = pane_id
	vim.b[bufnr].special_edit_cwd_uri = args.cwd_uri

	set_buffer_maps(bufnr)
	focus_buffer(bufnr)

	return nvim_pane_id or "ok"
end

function M.pick_pane()
	local output = vim.fn.system({
		wezterm_bin(),
		"cli",
		"list",
		"--format",
		"json",
	})

	if vim.v.shell_error ~= 0 then
		notify_error(("wezterm cli list failed: %s"):format(output))
		return
	end

	local ok, panes = pcall(vim.json.decode, output)
	if not ok or type(panes) ~= "table" then
		notify_error("wezterm cli list returned invalid json")
		return
	end

	local entries = vim.tbl_map(function(pane)
		return ("%s\t%s\t%s"):format(pane.pane_id, pane.title or "", pane.cwd or "")
	end, panes)

	require("fzf-lua").fzf_exec(entries, {
		prompt = "WezTerm pane> ",
		actions = {
			["default"] = function(selected)
				local pane_id = selected[1]:match("^(%d+)")
				if pane_id then
					M.open({ pane_id = tonumber(pane_id) })
				end
			end,
		},
	})
end

return M
