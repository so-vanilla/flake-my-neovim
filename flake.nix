{
  description = "Neovim and WezTerm configuration for an Emacs-style workflow";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    softpair = {
      url = "github:so-vanilla/softpair.nvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixvim,
      neovim-nightly-overlay,
      softpair,
      flake-utils,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      nvimServerPath = "\${XDG_RUNTIME_DIR:-/tmp}/my-neovim-\${USER:-user}/special-edit.sock";

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ neovim-nightly-overlay.overlays.default ];
        };

      mkNvimConfig =
        system:
        let
          pkgs = mkPkgs system;
        in
        nixvim.lib.evalNixvim {
          inherit system;
          modules = [
            ./nixvim
            {
              _module.args = {
                softpairPlugin = softpair.packages.${system}.default;
              };
              nixpkgs.pkgs = pkgs;
              package = pkgs.neovim;
            }
          ];
        };

      mkWeztermResetNvim =
        pkgs: nvimPackage:
        let
          mkEditorWrapper =
            name:
            pkgs.writeShellScriptBin name ''
              is_headless=0
              for arg in "$@"; do
                case "$arg" in
                  --headless)
                    is_headless=1
                    ;;
                esac
              done

              is_wezterm=0

              if [ -n "''${WEZTERM_PANE:-}" ]; then
                is_wezterm=1
              fi

              if [ "''${TERM_PROGRAM:-}" = "WezTerm" ]; then
                is_wezterm=1
              fi

              if [ "''${TERM:-}" = "wezterm" ]; then
                is_wezterm=1
              fi

              reset_wezterm_keyboard() {
                if [ "$is_headless" -eq 0 ] && [ "$is_wezterm" -eq 1 ]; then
                  ( printf '\033[=0u' > /dev/tty ) 2>/dev/null || true
                fi
              }

              trap reset_wezterm_keyboard EXIT

              "${nvimPackage}/bin/${name}" "$@"
              status=$?

              exit "$status"
            '';

          nvimWrapper = mkEditorWrapper "nvim";
          vimWrapper = mkEditorWrapper "vim";
          viWrapper = mkEditorWrapper "vi";
        in
        pkgs.symlinkJoin {
          name = "${nvimPackage.name}-wezterm-reset";
          paths = [ nvimPackage ];

          postBuild = ''
            rm -f "$out/bin/nvim" "$out/bin/vim" "$out/bin/vi"

            ln -s "${nvimWrapper}/bin/nvim" "$out/bin/nvim"
            ln -s "${vimWrapper}/bin/vim" "$out/bin/vim"
            ln -s "${viWrapper}/bin/vi" "$out/bin/vi"
          '';
        };

      mkWeztermResetCheck =
        pkgs: wrappedNvim:
        pkgs.runCommand "wezterm-reset-nvim-check" { } ''
          export HOME="$TMPDIR/home"
          export XDG_CACHE_HOME="$TMPDIR/cache"
          export XDG_CONFIG_HOME="$TMPDIR/config"
          export XDG_DATA_HOME="$TMPDIR/data"
          export XDG_STATE_HOME="$TMPDIR/state"
          mkdir -p "$HOME" "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"

          set +e
          "${wrappedNvim}/bin/nvim" --headless +'cq 42' > stdout.log
          status=$?
          set -e

          test "$status" -eq 42
          test ! -s stdout.log

          WEZTERM_PANE=1 "${wrappedNvim}/bin/nvim" --headless +'quit' > wezterm-headless.log
          test ! -s wezterm-headless.log

          "${wrappedNvim}/bin/nvim" --version > nvim-version.log
          "${wrappedNvim}/bin/vim" --version > vim-version.log
          "${wrappedNvim}/bin/vi" --version > vi-version.log

          touch "$out"
        '';

      mkWeztermConfigText =
        system:
        builtins.replaceStrings
          [
            "@NVIM_BIN@"
            "@NVIM_SERVER_PATH@"
          ]
          [
            "${self.packages.${system}.neovim}/bin/nvim"
            nvimServerPath
          ]
          (builtins.readFile ./wezterm/wezterm.lua);

      homeManagerModule =
        {
          lib,
          pkgs,
          ...
        }:
        let
          system = pkgs.stdenv.hostPlatform.system;
        in
        {
          home.packages = [
            self.packages.${system}.neovim
            pkgs.tmux
          ];

          home.sessionVariables = {
            EDITOR = lib.mkOverride 900 "nvim";
            VISUAL = lib.mkOverride 900 "nvim";
            WEZTERM_BIN = lib.mkDefault "${pkgs.wezterm}/bin/wezterm";
          };

          programs.wezterm = {
            enable = true;
            package = pkgs.wezterm;
            extraConfig = mkWeztermConfigText system;
          };
        };

      systemOutputs = flake-utils.lib.eachSystem systems (
        system:
        let
          pkgs = mkPkgs system;
          nvimConfig = mkNvimConfig system;
          nvimPackage = nvimConfig.config.build.package;
          wrappedNvimPackage = mkWeztermResetNvim pkgs nvimPackage;
          weztermConfigText = mkWeztermConfigText system;
          weztermConfig = pkgs.writeText "wezterm.lua" weztermConfigText;
        in
        {
          packages = {
            default = wrappedNvimPackage;
            neovim = wrappedNvimPackage;
            neovim-unwrapped = nvimPackage;
            wezterm-config = weztermConfig;
          };

          checks = {
            default = nvimConfig.config.build.test;
            nixvim = nvimConfig.config.build.test;
            softpair = softpair.checks.${system}.default;
            wezterm-reset-wrapper = mkWeztermResetCheck pkgs wrappedNvimPackage;
          };

          formatter = pkgs.nixfmt-tree;

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              devenv
              git
              nixd
              nixfmt
              stylua
            ];
          };

          homeManagerModules.default = homeManagerModule;
        }
      );
    in
    nixpkgs.lib.recursiveUpdate systemOutputs {
      homeManagerModules.default = homeManagerModule;
    };
}
