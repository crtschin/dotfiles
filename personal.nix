{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  home = rec {
    username = "crtschin";
    homeDirectory = "/home/${username}";
  };

  programs = {
    git = {
      userName = "crtschin";
      userEmail = "csochinjensem@gmail.com";
    };
  };
}
