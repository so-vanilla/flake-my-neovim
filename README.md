# flake-my-neovim

Emacs-style Neovim and WezTerm configuration managed by Nix.

## Shape

- Neovim is built by nixvim and exported as `packages.${system}.default`.
- Home Manager gets Neovim as a package instead of enabling `programs.neovim`.
- WezTerm is configured in the same flake because pane keys and special-edit are part of the editor workflow.
- tmux is installed for Claude Code terminal-jack experiments, but the config does not start or depend on tmux.
- org-mode is intentionally not included.

## WezTerm Keyboard Recovery

The exported Neovim package wraps nixvim's generated package. The wrapper calls
the generated store path directly, preserves Neovim's exit code, and then sends
`CSI < u` only when stdout is a TTY, `WEZTERM_PANE` is set, and Neovim was not
started with `--headless`.

`vim` and `vi` are aliases to the wrapped `nvim`, so they get the same WezTerm
keyboard recovery behavior.

## Special Edit

The intended layout is a persistent Neovim pane on the left and a terminal or Claude Code pane on the right.

- Press `M-i` in a WezTerm terminal pane to open a scratch buffer in the running Neovim server.
- Press `C-c '` in that scratch buffer to paste the text back to the original pane.
- Press `C-c C-c` to paste and send Enter.
- Press `C-c C-s` to wrap the buffer as a temporary shell script and run it in the target pane.
- Press `C-c C-k` to cancel.

Failure is explicit. If Neovim is not installed, the configured RPC socket is not available, or `wezterm cli` cannot target the pane, WezTerm or Neovim reports the failed boundary instead of falling back to a second editor instance. The RPC server is started only for an interactive Neovim UI, so flake checks and other headless commands do not create runtime sockets.

## Windows WezTerm

`wezterm/windows.wezterm.lua` is a copy-paste Windows config. It is not wired into the Nix outputs.

- Default WezTerm key bindings are disabled so Ctrl/Alt combinations are passed to the foreground program.
- The default entry point is WSL Ubuntu via `wsl.exe --distribution Ubuntu --cd ~`.
- `M-o` is the only reserved WezTerm leader; pane controls, reload, and debug overlay live under that prefix.
- Kitty keyboard protocol is enabled so Neovim can request disambiguated keys such as `C-d`, `C-i`, `C-m`, and `M-*`.
- Windows ConPTY win32 input mode is disabled for WSL/Neovim-oriented use because it takes precedence over CSI-u style encodings.
- Global CSI-u is left disabled because it changes shell behavior for keys such as `C-c` and `C-d`.
- Special Edit is intentionally omitted.
