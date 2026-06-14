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
    basedpyright
    bash-language-server
    deadnix
    dockerfile-language-server
    fd
    fzf
    git
    google-java-format
    gopls
    gotools
    hadolint
    jdt-language-server
    luajitPackages.luacheck
    markdownlint-cli
    marksman
    nixd
    nixfmt
    nodejs_24
    prettier
    ripgrep
    ruff
    shellcheck
    shfmt
    statix
    stylua
    taplo
    terraform-ls
    tflint
    wezterm
    vscode-langservers-extracted
    yaml-language-server
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

    local auto_insert_group = vim.api.nvim_create_augroup("MyAutoInsert", { clear = true })
    vim.api.nvim_create_autocmd({ "UIEnter", "BufEnter", "BufWinEnter", "WinEnter" }, {
      group = auto_insert_group,
      callback = function()
        require("my.editor").start_insert_if_editable()
      end,
    })
    require("my.editor").start_insert_if_editable()
  '';
}
