{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  programs = {
    neovim = {
      enable = true;
      extraConfig = ''
        syntax on
        set number relativenumber
      '';
      plugins = with pkgs.awesomeNeovimPlugins; [ ];
      viAlias = true;
      vimAlias = true;
    };
  };
}
