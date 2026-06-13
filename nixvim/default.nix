{
  pkgs,
  ...
}:
let
  rootMarkers = import ./root-markers.nix;
  rootMarkersLua = "{ " + builtins.concatStringsSep ", " (map builtins.toJSON rootMarkers) + " }";
in
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
    spell = false;
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
    deadnix
    luajitPackages.luacheck
    markdownlint-cli
    nil
    nixfmt
    ripgrep
    shellcheck
    shfmt
    statix
    stylua
    wezterm
  ];

  extraFiles = {
    "lua/my/editor.lua".source = ./lua/my/editor.lua;
    "lua/my/eval.lua".source = ./lua/my/eval.lua;
    "lua/my/hydras.lua".source = ./lua/my/hydras.lua;
    "lua/my/macro.lua".source = ./lua/my/macro.lua;
    "lua/my/project.lua".source = ./lua/my/project.lua;
    "lua/my/puni.lua".source = ./lua/my/puni.lua;
    "lua/my/region.lua".source = ./lua/my/region.lua;
    "lua/my/replace.lua".source = ./lua/my/replace.lua;
    "lua/my/root.lua".text = ''
      local M = {}

      M.markers = ${rootMarkersLua}

      function M.current_path()
        local path = vim.api.nvim_buf_get_name(0)
        if path == "" then
          return vim.uv.cwd()
        end
        return path
      end

      function M.root(path)
        return vim.fs.root(path or M.current_path(), M.markers) or vim.uv.cwd()
      end

      return M
    '';
    "lua/my/server.lua".source = ./lua/my/server.lua;
    "lua/my/special_edit.lua".source = ./lua/my/special_edit.lua;
  };

  extraConfigLuaPre = ''
    vim.fn.mkdir(vim.fn.stdpath("data"), "p")
    vim.fn.mkdir(vim.fn.stdpath("state"), "p")
    vim.g.project_history_no_data_notified = 1
    vim.g.nvim_surround_no_insert_mappings = true
  '';

  extraConfigLuaPost = ''
    require("my.hydras").setup()
    vim.env.WEZTERM_BIN = "${pkgs.wezterm}/bin/wezterm"
    if #vim.api.nvim_list_uis() > 0 then
      require("my.server").start()
    end
    vim.cmd.colorscheme("catppuccin-latte")
    vim.cmd.startinsert()
  '';
}
