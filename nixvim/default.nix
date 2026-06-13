{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./keymaps.nix
    ./plugins.nix
  ];

  viAlias = true;
  vimAlias = true;
  withNodeJs = true;
  withPython3 = true;

  globals = {
    mapleader = " ";
    maplocalleader = ",";
  };

  opts = {
    number = true;
    relativenumber = false;
    signcolumn = "yes";
    cursorline = true;
    expandtab = true;
    shiftwidth = 2;
    tabstop = 2;
    smartindent = true;
    ignorecase = true;
    smartcase = true;
    incsearch = true;
    hlsearch = true;
    termguicolors = true;
    clipboard = "unnamedplus";
    splitright = true;
    splitbelow = true;
    mouse = "a";
    undofile = true;
    updatetime = 250;
    timeout = true;
    timeoutlen = 700;
    completeopt = "menu,menuone,noselect";
  };

  extraPackages = with pkgs; [
    fd
    fzf
    git
    nil
    nixfmt
    ripgrep
    stylua
    wezterm
  ];

  extraFiles = {
    "lua/my/eval.lua".source = ./lua/my/eval.lua;
    "lua/my/server.lua".source = ./lua/my/server.lua;
    "lua/my/special_edit.lua".source = ./lua/my/special_edit.lua;
  };

  extraConfigLuaPost = ''
    vim.env.WEZTERM_BIN = "${pkgs.wezterm}/bin/wezterm"
    if #vim.api.nvim_list_uis() > 0 then
      require("my.server").start()
    end
    vim.cmd.colorscheme("catppuccin-latte")
    vim.cmd.startinsert()
  '';
}
