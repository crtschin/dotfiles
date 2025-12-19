{
  config,
  pkgs,
  inputs,
  lib,
  email,
  ...
}:
let
  overlay = self: super: {
    useWayland = true;
    configuration = {
      git = {
        userName = "Curtis Chin Jen Sem";
        userEmail = email;
        signingKey = "/home/curtis/.ssh/id_ed25519.pub";
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
  nixpkgs.overlays = overlays;

  imports = [
    ./common.nix
    ./home/modules/nixgl.nix
  ];

  targets.genericLinux = {
    enable = true;
    gpu = {
      enable = false;
    };
  };

  home = rec {
    username = "crtschin";
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      gv
      monitor-heap
      mermaid-cli
      # pgadmin4
      # solaar
      ltunify
      jmeter
      _1password-cli

      docker
      docker-compose
      devenv
      process-compose
      actionlint

      graphviz
      gprof2dot

      sqlite
      sqldiff
      # i3lock-color

      # Create .conf file in /etc/tmpfiles.d/ containing a symlink entry
      #     L+ /run/opengl-driver - - - - <nix-profile directory>
      #   Ensures drivers are symlinked nixos-style to make them accessible from
      #   nix-installed programs.
      mesa
      intel-media-driver

      # copilot-language-server
      github-copilot-cli
      gemini-cli
      # pkgs.haskellPackages.ghcprofview
      # pkgs.haskellPackages.hpview
    ];
  };

  services = {
    home-manager = {
      autoUpgrade = {
        enable = true;
        flakeDir = "/home/crtschin/personal/dotfiles";
        frequency = "weekly";
        useFlake = true;
      };
    };
  };

  programs = {
    fish = {
      shellInitLast = ''
        begin
          set fish_greeting
          set __done_notify_sound 1

          # Non-NixOS setting
          set --export NIX_PATH $NIX_PATH:$HOME/.nix-defexpr/channels
          set --export NIXPKGS_ALLOW_UNFREE 1
          set --export GIT_SSH "/usr/bin/ssh"

          . ${./.config/work.fish}
        end
      '';
    };
  };
}
