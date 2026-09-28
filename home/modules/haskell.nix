# The helix module wires treehouse as an LSP by store path, which leaves it off
# PATH. This module puts it there, so the binary is runnable by hand.
{
  lib,
  pkgs,
  inputs,
  system,
  ...
}:
{
  home.packages = lib.optionals pkgs.configuration.ghcCoreTools [
    inputs.treehouse.packages.${system}.treehouse
    inputs.coreviewer.packages.${system}.coreviewer
  ];
}
