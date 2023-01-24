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
      arandr
      curl
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
      package = pkgs.iosevka;
      name = "Iosevka crtschin";
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
      imageDirectory = "%h/backgrounds";
    };
  };

  programs = {
    git = {
      userName = "crtschin";
      userEmail = "csochinjensem@gmail.com";
    };
  };
}
