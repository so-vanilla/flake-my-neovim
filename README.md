# flake-my-neovim

Emacs-style Neovim and WezTerm configuration managed by Nix.

## Shape

- Neovim is built by nixvim and exported as `packages.${system}.default`.
- Home Manager gets Neovim as a package instead of enabling `programs.neovim`.
- WezTerm is configured in the same flake because pane keys and special-edit are part of the editor workflow.
- tmux is installed for Claude Code terminal-jack experiments, but the config does not start or depend on tmux.
- org-mode is intentionally not included.

## Special Edit

The intended layout is a persistent Neovim pane on the left and a terminal or Claude Code pane on the right.

- Press `M-i` in a WezTerm terminal pane to open a scratch buffer in the running Neovim server.
- Press `C-c '` in that scratch buffer to paste the text back to the original pane.
- Press `C-c C-c` to paste and send Enter.
- Press `C-c C-s` to wrap the buffer as a temporary shell script and run it in the target pane.
- Press `C-c C-k` to cancel.

Failure is explicit. If Neovim is not installed, the configured RPC socket is not available, or `wezterm cli` cannot target the pane, WezTerm or Neovim reports the failed boundary instead of falling back to a second editor instance. The RPC server is started only for an interactive Neovim UI, so flake checks and other headless commands do not create runtime sockets.
