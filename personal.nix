{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  home = rec {
    username = "crtschin";
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      git
      htop
      tig
      arandr
      curl
      fd
      feh
      file
      wget
      gcc
      python
      rustc
      rustfmt
      cargo
    ];
  };

  gtk = {
    enable = true;
    font = {
      package = pkgs.fira-code;
      name = "Fira Code";
      size = 12;
    };
    theme = {
      name = "gruvbox-dark";
      package = pkgs.gruvbox-dark-gtk;
    };
    iconTheme = {
      name = "gruvbox-dark";
      package = pkgs.gruvbox-dark-icons-gtk;
    };
  };

  services = {
    random-background = {
      enable = true;
    };
  };

  programs = {
    git = {
      userName = "crtschin";
      userEmail = "csochinjensem@gmail.com";
    };
  };
}
