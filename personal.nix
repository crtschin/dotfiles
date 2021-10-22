{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  home = rec {
    username = "crtschin";
    homeDirectory = "/home/${username}";
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
