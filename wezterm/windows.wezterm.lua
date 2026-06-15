local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Latte"
config.term = "wezterm"
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.window_close_confirmation = "NeverPrompt"
config.scrollback_lines = 20000

-- Keep Ctrl/Alt combinations available to the foreground program.
-- Re-add only the terminal-level keys that are part of this workflow.
config.disable_default_key_bindings = true

-- Prefer an app-negotiated keyboard protocol. Neovim can request this and then
-- distinguish C-d, C-i, C-m, Alt keys, and shifted modifier combinations.
config.enable_kitty_keyboard = true

-- On Windows this defaults to true and takes precedence over CSI-u. Disable it
-- for WSL/Neovim-oriented use so that WezTerm's negotiated encodings are stable.
config.allow_win32_input_mode = false

-- Leave this off for shells. Turning it on globally makes keys such as C-c and
-- C-d stop behaving like legacy terminal control characters unless the program
-- understands CSI-u.
config.enable_csi_u_key_encoding = false

-- Do not treat left Ctrl+Alt as AltGr. This keeps C-M-* mappings distinguishable.
config.treat_left_ctrlalt_as_altgr = false

-- Uncomment and adjust if the desired default is WSL rather than PowerShell.
-- config.default_prog = { "wsl.exe", "--cd", "~" }

config.leader = {
	key = "o",
	mods = "ALT",
	timeout_milliseconds = 1500,
}

config.keys = {
	{
		key = "o",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Next"),
	},
	{
		key = "2",
		mods = "LEADER",
		action = act.SplitPane({
			direction = "Down",
			size = { Percent = 35 },
		}),
	},
	{
		key = "3",
		mods = "LEADER",
		action = act.SplitPane({
			direction = "Right",
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
	{
		key = "d",
		mods = "LEADER",
		action = act.ShowDebugOverlay,
	},
	{
		key = "r",
		mods = "LEADER",
		action = act.ReloadConfiguration,
	},
}

return config
