{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  home = rec {
    username = "crtschin";
  };

  programs = {
    git = {
      userName = "crtschin";
      userEmail = "csochinjensem@gmail.com";
    };
  };
}
