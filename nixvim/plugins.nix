{
  pkgs,
  config,
  softpairPlugin,
  ...
}:
let
  rootMarkers = import ./root-markers.nix;
  nvimLibmodal = pkgs.vimUtils.buildVimPlugin {
    pname = "nvim-libmodal";
    version = "3.5.0";
    src = pkgs.fetchFromGitHub {
      owner = "Iron-E";
      repo = "nvim-libmodal";
      rev = "v3.5.0";
      hash = "sha256-3BLBJ72e3v1UzGFmKPMbeCN9Sqm/iv8XMQ5iem6I4kg=";
    };
  };
  fzfBottomWinopts = {
    height = 8;
    width = 1;
    row = 1;
    col = 0;
    border = "none";
    backdrop = 100;
    preview = {
      hidden = true;
      layout = "vertical";
      vertical = "up:0%";
      horizontal = "right:0%";
      border = "none";
      title = false;
      scrollbar = false;
    };
  };
in
{
  extraPlugins = [
    pkgs.vimPlugins.flatten-nvim
    nvimLibmodal
    softpairPlugin
  ];

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
      integrations = {
        blink_cmp = {
          enabled = true;
          style = "bordered";
        };
        diffview = true;
        fzf = true;
        gitsigns = true;
        grug_far = true;
        mini.enabled = true;
        neogit = true;
        rainbow_delimiters = true;
        treesitter = true;
        which_key = true;
      };
    };
  };

  plugins = {
    fzf-lua = {
      enable = true;
      profile = null;
      settings = {
        "__unkeyed-0" = "ivy";
        fzf_colors = true;
        fzf_opts = {
          "--layout" = "default";
        };
        winopts = fzfBottomWinopts;
        keymap = {
          fzf = {
            __raw = ''
              {
                ["ctrl-g"] = "abort",
                ["ctrl-q"] = "select-all+accept",
                ["ctrl-u"] = "half-page-up",
                ["ctrl-d"] = "half-page-down",
                ["ctrl-k"] = "kill-line",
              }
            '';
          };
        };
        ui_select = {
          winopts = {
            height = 0.4;
            width = 0.55;
          };
        };
        oldfiles.include_current_session = true;
        files = {
          cwd_prompt = true;
          cwd_prompt_shorten_len = 32;
        };
        grep = {
          rg_glob = true;
          glob_flag = "--iglob";
          actions = {
            "ctrl-g" = false;
          };
        };
        grep_curbuf = {
          previewer = "swiper";
          winopts = fzfBottomWinopts;
          actions = {
            "ctrl-g" = false;
          };
        };
        lgrep_curbuf = {
          previewer = "swiper";
          winopts = fzfBottomWinopts;
        };
        tags.actions."ctrl-g" = false;
        blines = {
          previewer = "swiper";
          winopts = fzfBottomWinopts;
        };
        treesitter = {
          previewer = "swiper";
          winopts = fzfBottomWinopts;
        };
        git.blame = {
          previewer = "swiper";
          winopts = fzfBottomWinopts;
        };
        lsp = {
          document_symbols = {
            previewer = "swiper";
            winopts = fzfBottomWinopts;
          };
          workspace_symbols.actions."ctrl-g" = false;
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

    treesitter-context = {
      enable = true;
      settings = {
        enable = true;
        max_lines = 3;
        min_window_height = 20;
        line_numbers = true;
        multiline_threshold = 4;
        trim_scope = "outer";
        mode = "cursor";
        zindex = 20;
        on_attach = {
          __raw = ''
            function(bufnr)
              return not require("my.special_ui").is_special(bufnr)
            end
          '';
        };
      };
    };

    overseer = {
      enable = true;
      settings = {
        dap = false;
        output = {
          use_terminal = false;
          preserve_output = false;
        };
        task_list = {
          direction = "bottom";
          min_height = 6;
          max_height = [
            12
            0.25
          ];
          min_width = [
            40
            0.1
          ];
          max_width = [
            100
            0.25
          ];
          keymaps = {
            "<C-e>" = false;
            "<C-f>" = false;
            "<C-j>" = false;
            "<C-k>" = false;
            "<C-s>" = false;
            "<C-v>" = false;
            "<C-t>" = false;
            "<C-q>" = {
              __unkeyed-1 = "keymap.run_action";
              opts.action = "open output in quickfix";
              desc = "Open task output in quickfix";
            };
            q = {
              __unkeyed-1 = "<Cmd>close<CR>";
              desc = "Close task list";
            };
          };
        };
        form = {
          border = "single";
          min_width = 70;
          max_width = 0.8;
          min_height = 8;
          max_height = 0.8;
        };
        task_win = {
          border = "single";
          padding = 1;
        };
        component_aliases = {
          default = [
            "on_exit_set_status"
            "on_complete_notify"
            {
              __unkeyed-1 = "on_complete_dispose";
              require_view = [
                "SUCCESS"
                "FAILURE"
              ];
              timeout = 60;
            }
          ];
          default_vscode = [
            "default"
            "on_result_diagnostics"
          ];
          default_builtin = [
            "on_exit_set_status"
            {
              __unkeyed-1 = "on_complete_dispose";
              timeout = 30;
            }
            {
              __unkeyed-1 = "unique";
              soft = true;
            }
          ];
        };
        template_timeout_ms = 3000;
        template_cache_threshold_ms = 200;
        log_level = {
          __raw = "vim.log.levels.WARN";
        };
      };
    };

    grug-far = {
      enable = true;
      settings = {
        debounceMs = 300;
        maxSearchMatches = 2000;
        maxWorkers = 8;
        minSearchChars = 1;
        normalModeSearch = true;
        startInInsertMode = true;
        engine = "ripgrep";
        engines.ripgrep = {
          path = "rg";
          showReplaceDiff = true;
        };
      };
    };

    project-nvim = {
      enable = true;
      settings = {
        manual_mode = true;
        enable_autochdir = false;
        silent_chdir = true;
        scope_chdir = "win";
        show_hidden = true;
        patterns = rootMarkers;
        history.size = 200;
        fzf_lua = {
          enabled = true;
          show = "paths";
          sort = "newest";
        };
      };
    };

    mini = {
      enable = true;
      modules.ai = {
        n_lines = 500;
        search_method = "cover_or_nearest";
        silent = true;
      };
    };

    comment = {
      enable = true;
      settings = {
        mappings = false;
        padding = true;
        sticky = true;
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
            __unkeyed-1 = "<F1>";
            group = "Help";
          }
          {
            __unkeyed-1 = "<C-x>";
            group = "Emacs prefix";
          }
          {
            __unkeyed-1 = "<C-x><C-k>";
            group = "Keyboard macro";
          }
          {
            __unkeyed-1 = "<C-x>p";
            group = "Project";
          }
          {
            __unkeyed-1 = "<C-x>g";
            group = "Git";
          }
          {
            __unkeyed-1 = "<C-c>^";
            group = "Git conflict";
          }
          {
            __unkeyed-1 = "<M-l>";
            group = "LSP";
          }
        ];
      };
    };

    blink-cmp = {
      enable = true;
      setupLspCapabilities = true;
      settings = {
        enabled = {
          __raw = ''
            function()
              local disabled_filetypes = {
                ["grug-far"] = true,
                NeogitStatus = true,
                oil = true,
              }
              return not disabled_filetypes[vim.bo.filetype]
                and vim.bo.buftype ~= "prompt"
                and vim.b.completion ~= false
            end
          '';
        };
        appearance = {
          use_nvim_cmp_as_default = false;
          nerd_font_variant = "mono";
        };
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
          "<Tab>" = [
            "select_and_accept"
            "snippet_forward"
            "fallback"
          ];
          "<C-i>" = [
            "select_and_accept"
            "snippet_forward"
            "fallback"
          ];
          "<S-Tab>" = [
            "snippet_backward"
            "fallback"
          ];
          "<CR>" = [
            "accept"
            "fallback"
          ];
          "<C-m>" = [
            "accept"
            "fallback"
          ];
        };
        completion = {
          menu = {
            border = "single";
            max_height = 12;
            draw.treesitter = [ "lsp" ];
          };
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 200;
            window.border = "single";
          };
          ghost_text.enabled = false;
          list.selection = {
            preselect = false;
            auto_insert = false;
          };
        };
        signature = {
          enabled = true;
          window.border = "single";
        };
        cmdline = {
          enabled = true;
          keymap = {
            preset = "cmdline";
            "<C-n>" = [
              "select_next"
              "fallback"
            ];
            "<C-p>" = [
              "select_prev"
              "fallback"
            ];
            "<CR>" = [
              "accept_and_enter"
              "fallback"
            ];
            "<C-m>" = [
              "accept_and_enter"
              "fallback"
            ];
            "<Left>" = false;
            "<Right>" = false;
          };
          completion = {
            list.selection.preselect = false;
            menu.auto_show = {
              __raw = ''
                function()
                  return vim.fn.getcmdtype() == ":"
                end
              '';
            };
            ghost_text.enabled = false;
          };
        };
        sources = {
          default = [
            "lsp"
            "path"
            "buffer"
          ];
          providers = {
            path.score_offset = 3;
            lsp.score_offset = 0;
            buffer.score_offset = -3;
          };
        };
      };
    };

    lsp = {
      enable = true;
      inlayHints = true;
      servers = {
        basedpyright.enable = true;
        bashls.enable = true;
        dockerls.enable = true;
        gopls.enable = true;
        jdtls.enable = true;
        jsonls = {
          enable = true;
          settings = {
            format.enable = true;
            validate.enable = true;
          };
        };
        lua_ls = {
          enable = true;
          settings = {
            diagnostics.globals = [ "vim" ];
            workspace.checkThirdParty = false;
          };
        };
        marksman.enable = true;
        nixd = {
          enable = true;
          settings = {
            formatting.command = [ "nixfmt" ];
          };
        };
        ruff.enable = true;
        taplo.enable = true;
        terraformls.enable = true;
        yamlls = {
          enable = true;
          settings = {
            completion = true;
            hover = true;
            validate = true;
          };
        };
      };
    };

    schemastore = {
      enable = true;
      json.enable = true;
      yaml.enable = true;
    };

    treesitter = {
      enable = true;
      grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
        bash
        diff
        dockerfile
        gitcommit
        gitignore
        go
        gomod
        gosum
        gowork
        hcl
        java
        json
        lua
        luadoc
        markdown
        markdown_inline
        nix
        python
        query
        regex
        terraform
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
      autoInstall.enable = true;
      settings = {
        format_on_save = {
          timeout_ms = 3000;
          lsp_format = "fallback";
        };
        formatters_by_ft = {
          bash = [ "shfmt" ];
          go = [ "goimports" ];
          java = [ "google-java-format" ];
          json = [ "prettier" ];
          lua = [ "stylua" ];
          markdown = [ "prettier" ];
          nix = [ "nixfmt" ];
          python = [ "ruff_format" ];
          sh = [ "shfmt" ];
          toml = [ "taplo" ];
          yaml = [ "prettier" ];
        };
      };
    };

    lint = {
      enable = true;
      autoInstall = {
        enable = true;
        overrides = {
          luacheck = pkgs.luajitPackages.luacheck;
          markdownlint = pkgs.markdownlint-cli;
        };
      };
      lintersByFt = {
        bash = [ "shellcheck" ];
        dockerfile = [ "hadolint" ];
        lua = [ "luacheck" ];
        markdown = [ "markdownlint" ];
        nix = [
          "deadnix"
          "statix"
        ];
        python = [ "ruff" ];
        sh = [ "shellcheck" ];
        terraform = [ "tflint" ];
        tf = [ "tflint" ];
      };
      autoCmd.event = [
        "BufWritePost"
        "InsertLeave"
      ];
      autoCmd.callback = {
        __raw = ''
          function()
            if vim.bo.buftype ~= "" or vim.b.lint == false then
              return
            end
            require("lint").try_lint()
          end
        '';
      };
    };
    gitsigns = {
      enable = true;
      settings = {
        signs = {
          add.text = "│";
          change.text = "│";
          delete.text = "_";
          topdelete.text = "‾";
          changedelete.text = "~";
          untracked.text = "┆";
        };
        signcolumn = true;
        numhl = false;
        linehl = false;
        word_diff = false;
        watch_gitdir.follow_files = true;
        attach_to_untracked = true;
        current_line_blame = false;
        current_line_blame_opts = {
          delay = 800;
          virt_text_pos = "eol";
        };
      };
    };
    diffview = {
      enable = true;
      settings = {
        enhanced_diff_hl = true;
        view.merge_tool = {
          layout = "diff3_mixed";
          disable_diagnostics = true;
          winbar_info = true;
        };
        file_panel = {
          listing_style = "tree";
          tree_options.flatten_dirs = true;
        };
      };
    };
    neogit = {
      enable = true;
      settings = {
        kind = "tab";
        graph_style = "unicode";
        disable_hint = false;
        disable_insert_on_commit = "auto";
        remember_settings = true;
        use_per_project_settings = true;
        integrations = {
          diffview = true;
          fzf_lua = true;
        };
        commit_editor = {
          kind = "tab";
          show_staged_diff = true;
          staged_diff_split_kind = "split";
          spell_check = false;
        };
        sections = {
          untracked.folded = false;
          unstaged.folded = false;
          staged.folded = false;
          stashes.folded = true;
          recent.folded = true;
        };
      };
    };
    git-conflict = {
      enable = true;
      settings = {
        default_mappings = false;
        default_commands = true;
        disable_diagnostics = true;
        list_opener = "copen";
      };
    };
    oil = {
      enable = true;
      settings = {
        default_file_explorer = true;
        columns = [
          "type"
          "size"
          "mtime"
        ];
        delete_to_trash = true;
        skip_confirm_for_simple_edits = false;
        prompt_save_on_select_new_entry = true;
        keymaps = {
          "<C-c>" = false;
          "<C-h>" = false;
          "<C-s>" = false;
          "q" = "actions.close";
        };
        view_options = {
          show_hidden = true;
          natural_order = "fast";
          sort = [
            [
              "type"
              "asc"
            ]
            [
              "name"
              "asc"
            ]
          ];
        };
        win_options = {
          wrap = false;
          signcolumn = "no";
          cursorcolumn = false;
          foldcolumn = "0";
          spell = false;
          list = false;
          conceallevel = 3;
          concealcursor = "ncv";
        };
      };
    };
    lualine = {
      enable = true;
      settings = {
        options = {
          theme = "catppuccin";
          globalstatus = true;
          component_separators = {
            left = "";
            right = "";
          };
          section_separators = {
            left = "";
            right = "";
          };
          disabled_filetypes.statusline = [
            "grug-far"
            "oil"
          ];
        };
        sections = {
          lualine_a = [ "mode" ];
          lualine_b = [
            "branch"
            "diff"
            "diagnostics"
          ];
          lualine_c = [
            {
              __unkeyed-1 = "filename";
              path = 1;
            }
          ];
          lualine_x = [
            "encoding"
            "filetype"
          ];
          lualine_y = [ "progress" ];
          lualine_z = [ "location" ];
        };
      };
    };
    nvim-surround.enable = true;
    rainbow-delimiters = {
      enable = true;
      strategy = {
        "" = "global";
        clojure = "local";
        commonlisp = "local";
        fennel = "local";
        janet_simple = "local";
        scheme = "local";
      };
      settings.blacklist = [
        "markdown"
        "toml"
        "yaml"
      ];
    };
  };
}
