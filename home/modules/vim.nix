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
      plugins = with pkgs.awesomeNeovimPlugins; with pkgs.vimPlugins; [
        # vim-cool
        # vim-airline
        # vim-tidal
        # (nvim-treesitter.withPlugins (p: [ p.haskell ]))
        # vim-surround
      ];
      viAlias = true;
      vimAlias = true;
    };
  };
}
