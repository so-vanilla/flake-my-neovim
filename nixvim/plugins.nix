{
  pkgs,
  lib,
  config,
  ...
}:
{
  colorschemes.catppuccin = {
    enable = true;
    settings = {
      flavour = "latte";
      transparent_background = false;
      term_colors = true;
      styles = {
        comments = [ "italic" ];
        conditionals = [ ];
        keywords = [ ];
      };
    };
  };

  plugins = {
    fzf-lua = {
      enable = true;
      profile = "fzf-native";
      settings = {
        winopts = {
          height = 0.86;
          width = 0.92;
          row = 0.5;
          col = 0.5;
          preview = {
            layout = "horizontal";
            horizontal = "right:55%";
          };
        };
        keymap = {
          builtin = {
            __raw = ''
              {
                ["<C-f>"] = "preview-page-down",
                ["<C-b>"] = "preview-page-up",
              }
            '';
          };
        };
      };
    };

    flash = {
      enable = true;
      settings = {
        labels = "asdfghjklqwertyuiopzxcvbnm";
        modes.search.enabled = true;
      };
    };

    hydra = {
      enable = true;
      settings = {
        hint = {
          float_opts.border = "rounded";
        };
      };
    };

    which-key = {
      enable = true;
      settings = {
        preset = "modern";
        delay = 250;
        notify = false;
        win.border = "single";
        spec = [
          {
            __unkeyed-1 = "M-o";
            group = "WezTerm panes";
          }
          {
            __unkeyed-1 = "C-x";
            group = "Emacs prefix";
          }
          {
            __unkeyed-1 = "M-l";
            group = "LSP";
          }
        ];
      };
    };

    blink-cmp = {
      enable = true;
      setupLspCapabilities = true;
      settings = {
        keymap = {
          preset = "none";
          "<C-n>" = [
            "select_next"
            "fallback"
          ];
          "<C-p>" = [
            "select_prev"
            "fallback"
          ];
          "<C-y>" = [
            "select_and_accept"
          ];
          "<Tab>" = [
            "snippet_forward"
            "fallback"
          ];
          "<S-Tab>" = [
            "snippet_backward"
            "fallback"
          ];
        };
        completion = {
          documentation.auto_show = true;
          list.selection.preselect = false;
        };
        signature.enabled = true;
        sources.default = [
          "lsp"
          "path"
          "snippets"
          "buffer"
        ];
      };
    };

    lsp = {
      enable = true;
      inlayHints = true;
      servers = {
        nil_ls = {
          enable = true;
          settings = {
            formatting.command = [ "nixfmt" ];
          };
        };
        lua_ls = {
          enable = true;
          settings = {
            Lua = {
              diagnostics.globals = [ "vim" ];
              workspace.checkThirdParty = false;
            };
          };
        };
      };
    };

    treesitter = {
      enable = true;
      grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
        bash
        json
        lua
        markdown
        markdown_inline
        nix
        regex
        toml
        vim
        vimdoc
        yaml
      ];
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
    };

    conform-nvim = {
      enable = true;
      settings = {
        format_on_save = {
          timeout_ms = 1000;
          lsp_format = "fallback";
        };
        formatters_by_ft = {
          lua = [ "stylua" ];
          nix = [ "nixfmt" ];
        };
      };
    };

    lint.enable = true;
    gitsigns.enable = true;
    diffview.enable = true;
    neogit.enable = true;
    oil.enable = true;
    lualine.enable = true;
    nvim-autopairs.enable = true;
    nvim-surround.enable = true;
    rainbow-delimiters.enable = true;
  };
}
