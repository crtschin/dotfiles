{
  config,
  pkgs,
  lib,
  inputs,
  email,
  ...
}:
let
  overlay = self: super: {
    configuration = {
      git = {
        userEmail = email;
        userName = "crtschin";
        signingKey = "/home/crtschin/.ssh/id_rsa.pub";
      };
      wm = "sway";
    };
  };

  overlays = [
    overlay
    (import ./home/overlays/entry.nix)
    (import ./home/overlays/kanshi.nix)
    (import ./home/overlays/rice.nix)
    (import ./home/overlays/wm.nix)
  ];
in
{
  imports = [
    ./common.nix
  ];

  nixpkgs.overlays = overlays;

  home = rec {
    username = "crtschin";
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      pciutils
      iotop
      pv
      valgrind
      discord
      mesa-demos
      unzip
      time
      mold
      mediawriter

      docker
      docker-compose
      devenv
      git
      htop
      curl
      feh
      file
      wget
      gcc
      python3
      rustc
      rustfmt
      cargo

      vlc
      filezilla
    ];
  };

  services = {
    ssh-agent.enable = true;
    # gnome-keyring.enable = true;
    udiskie.enable = true;
  };

  programs = {
    fish = {
      shellInit = ''
        begin
          set fish_greeting
          set __done_notify_sound 1
        end
      '';
    };
  };
}
