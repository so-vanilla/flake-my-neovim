{
  lib,
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

  extraPackages =
    (with pkgs; [
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
      vscode-langservers-extracted
      yaml-language-server
    ])
    ++ lib.optionals pkgs.stdenv.isLinux (
      with pkgs;
      [
        wl-clipboard
      ]
    );

  extraFiles = {
    "after/ftplugin/NeogitStatus.lua".source = ./after/ftplugin/NeogitStatus.lua;
    "after/ftplugin/_special_ui.lua".source = ./after/ftplugin/_special_ui.lua;
    "after/ftplugin/grug-far.lua".source = ./after/ftplugin/grug-far.lua;
    "after/ftplugin/help.lua".source = ./after/ftplugin/help.lua;
    "after/ftplugin/man.lua".source = ./after/ftplugin/man.lua;
    "after/ftplugin/oil.lua".source = ./after/ftplugin/oil.lua;
    "after/ftplugin/qf.lua".source = ./after/ftplugin/qf.lua;
    "lua/my/editor.lua".source = ./lua/my/editor.lua;
    "lua/my/eval.lua".source = ./lua/my/eval.lua;
    "lua/my/hydras.lua".source = ./lua/my/hydras.lua;
    "lua/my/macro.lua".source = ./lua/my/macro.lua;
    "lua/my/project.lua".source = ./lua/my/project.lua;
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
    require("flatten").setup({
      block_for = {
        gitcommit = true,
        gitrebase = true,
      },
      nest_if_no_args = false,
      allow_cmd_passthrough = true,
      window = {
        open = "current",
        diff = "tab_vsplit",
        focus = "first",
      },
      integrations = {
        wezterm = true,
        kitty = false,
      },
      hooks = {
        should_block = function(argv)
          return vim.g.flatten_wait == 1 or vim.tbl_contains(argv, "-b")
        end,
        post_open = function(opts)
          if not opts.is_blocking and opts.winnr and vim.api.nvim_win_is_valid(opts.winnr) then
            vim.api.nvim_set_current_win(opts.winnr)
            require("my.editor").start_insert_if_editable()
          end
        end,
      },
    })
  '';

  extraConfigLuaPost = ''
    require("softpair").setup({
      mappings = true,
      disabled_filetypes = {
        fzf = true,
        ["grug-far"] = true,
        help = true,
        man = true,
        NeogitStatus = true,
        oil = true,
        qf = true,
      },
      disabled_buftypes = {
        nofile = true,
        prompt = true,
        quickfix = true,
        terminal = true,
      },
    })
    require("my.hydras").setup()
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
    vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
      group = auto_insert_group,
      pattern = { "oil", "NeogitStatus", "help", "qf" },
      callback = function()
        vim.schedule(function()
          require("my.editor").stop_insert()
        end)
      end,
    })
    require("my.editor").start_insert_if_editable()
  '';
}
