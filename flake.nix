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
          weztermConfigText = mkWeztermConfigText system;
          weztermConfig = pkgs.writeText "wezterm.lua" weztermConfigText;
        in
        {
          packages = {
            default = nvimPackage;
            neovim = nvimPackage;
            wezterm-config = weztermConfig;
          };

          checks = {
            default = nvimConfig.config.build.test;
            nixvim = nvimConfig.config.build.test;
            softpair = softpair.checks.${system}.default;
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
