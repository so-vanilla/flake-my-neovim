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

	local output = vim.fn.system({
		wezterm_bin(),
		"cli",
		"send-text",
		"--pane-id",
		tostring(pane_id),
	}, text)

	if vim.v.shell_error ~= 0 then
		notify_error(("wezterm cli send-text failed: %s"):format(output))
		return false
	end

	return true
end

local function close_special_buffer(bufnr)
	if vim.api.nvim_buf_is_valid(bufnr) then
		vim.api.nvim_buf_delete(bufnr, { force = true })
	end
end

local function shell_script_payload(text)
	return table.concat({
		[[tmp=$(mktemp "${TMPDIR:-/tmp}/nvim-special-edit.XXXXXX.sh") || exit]],
		[[cat > "$tmp" <<'__NVIM_SPECIAL_EDIT__']],
		text,
		[[__NVIM_SPECIAL_EDIT__]],
		[[${SHELL:-sh} "$tmp"]],
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

function M.open(args)
	args = args or {}
	local pane_id = args.pane_id

	if not pane_id then
		notify_error("missing target pane id")
		return "missing pane id"
	end

	state.last_pane_id = pane_id

	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(bufnr, ("special-edit://wezterm-pane/%s"):format(pane_id))
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
		"",
	})
	vim.bo[bufnr].buftype = "nofile"
	vim.bo[bufnr].bufhidden = "wipe"
	vim.bo[bufnr].swapfile = false
	vim.bo[bufnr].filetype = args.filetype or "markdown"
	vim.b[bufnr].special_edit_pane_id = pane_id
	vim.b[bufnr].special_edit_cwd_uri = args.cwd_uri

	vim.cmd("botright split")
	vim.api.nvim_win_set_buf(0, bufnr)
	vim.api.nvim_win_set_height(0, math.max(8, math.floor(vim.o.lines * 0.35)))
	set_buffer_maps(bufnr)
	vim.cmd.startinsert()

	return "ok"
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
