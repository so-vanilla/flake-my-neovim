local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

local nvim_bin = "@NVIM_BIN@"
local nvim_server_path = "@NVIM_SERVER_PATH@"

local function expand_server_path()
	local runtime = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
	local user = os.getenv("USER") or "user"
	return nvim_server_path:gsub("${XDG_RUNTIME_DIR:-/tmp}", runtime):gsub("${USER:-user}", user)
end

local function vim_quote(value)
	return "'" .. tostring(value):gsub("'", "''") .. "'"
end

local function pane_cwd_uri(pane)
	local cwd = pane:get_current_working_dir()
	if cwd == nil then
		return nil
	end
	return tostring(cwd)
end

local function open_special_edit(window, pane)
	local pane_id = pane:pane_id()
	local cwd_uri = pane_cwd_uri(pane)
	local lua_code = "require('my.special_edit').open(_A)"
	local args = "{'pane_id': " .. tostring(pane_id)

	if cwd_uri ~= nil and cwd_uri ~= "" then
		args = args .. ", 'cwd_uri': " .. vim_quote(cwd_uri)
	end

	args = args .. "}"

	local expr = "luaeval(" .. vim_quote(lua_code) .. ", " .. args .. ")"
	local ok, stdout, stderr = wezterm.run_child_process({
		nvim_bin,
		"--server",
		expand_server_path(),
		"--remote-expr",
		expr,
	})

	if not ok then
		local message = stderr
		if message == nil or message == "" then
			message = stdout
		end
		if message == nil or message == "" then
			message = "nvim RPC call failed"
		end
		wezterm.log_error(message)
		window:toast_notification("special-edit", message, nil, 5000)
		return
	end

	window:perform_action(act.ActivatePaneDirection("Left"), pane)
end

config.color_scheme = "Catppuccin Latte"
config.term = "wezterm"
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.window_close_confirmation = "NeverPrompt"
config.scrollback_lines = 20000

config.leader = {
	key = "o",
	mods = "ALT",
	timeout_milliseconds = 1500,
}

config.keys = {
	{
		key = "i",
		mods = "ALT",
		action = wezterm.action_callback(open_special_edit),
	},
	{
		key = "o",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Next"),
	},
	{
		key = "2",
		mods = "LEADER",
		action = act.SplitPane({
			direction = "Right",
			size = { Percent = 35 },
		}),
	},
	{
		key = "3",
		mods = "LEADER",
		action = act.SplitPane({
			direction = "Down",
			size = { Percent = 35 },
		}),
	},
	{
		key = "0",
		mods = "LEADER",
		action = act.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "h",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "j",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "l",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Right"),
	},
}

return config
