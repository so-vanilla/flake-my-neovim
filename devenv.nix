{ pkgs, ... }:
{
  packages = with pkgs; [
    git
    nixd
    nixfmt
    stylua
  ];

  scripts.check.exec = ''
    nix flake check
  '';

  enterTest = ''
    nix flake check
  '';
}
