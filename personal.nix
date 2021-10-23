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
    };
  };

  programs = {
    git = {
      userName = "crtschin";
      userEmail = "csochinjensem@gmail.com";
    };
  };
}
