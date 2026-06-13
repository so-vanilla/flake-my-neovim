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
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixvim,
      neovim-nightly-overlay,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachSystem [
      "x86_64-linux"
      "aarch64-darwin"
    ] (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ neovim-nightly-overlay.overlays.default ];
        };

        nvimServerPath = "\${XDG_RUNTIME_DIR:-/tmp}/my-neovim-\${USER:-user}/special-edit.sock";

        nvimConfig = nixvim.lib.evalNixvim {
          inherit system;
          modules = [
            ./nixvim
            {
              nixpkgs.pkgs = pkgs;
              package = pkgs.neovim;
            }
          ];
        };

        nvimPackage = nvimConfig.config.build.package;

        weztermConfigText =
          builtins.replaceStrings
            [
              "@NVIM_BIN@"
              "@NVIM_SERVER_PATH@"
            ]
            [
              "${nvimPackage}/bin/nvim"
              nvimServerPath
            ]
            (builtins.readFile ./wezterm/wezterm.lua);

        weztermConfig = pkgs.writeText "wezterm.lua" weztermConfigText;
      in
      {
        packages = {
          default = nvimPackage;
          neovim = nvimPackage;
          wezterm-config = weztermConfig;
        };

        checks.default = nvimConfig.config.build.test;

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

        homeManagerModules.default =
          { lib, ... }:
          {
            home.packages = with pkgs; [
              nvimPackage
              wezterm
              tmux
            ];

            home.sessionVariables = {
              EDITOR = lib.mkOverride 900 "nvim";
              VISUAL = lib.mkOverride 900 "nvim";
            };

            programs.wezterm = {
              enable = true;
              extraConfig = weztermConfigText;
            };
          };
      }
    );
}
