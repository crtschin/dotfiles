{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  programs = {
    vim = {
      enable = true;
      package = pkgs.neovim;
      extraConfig = ''
        syntax on
      '';
    };
  };
}
