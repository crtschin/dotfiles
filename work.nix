{
  config,
  pkgs,
  inputs,
  ...
}:
let
  overlay = self: super: {
    useWayland = true;
    # betterlockscreen = self.native_wrapper super.betterlockscreen;
    # i3lock-color = self.native_wrapper super.i3lock-color;
  };
in
{
  nixpkgs.overlays = [ overlay ];

  imports = [
    ./common.nix
    ./home/modules/nixgl.nix
    ./home/modules/general-overlay.nix
  ];

  targets.genericLinux.enable = true;

  home = rec {
    username = "curtis";
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      gv
      monitor-heap
      mermaid-cli
      pgcli
      # pgadmin4
      # solaar
      ltunify
      jmeter
      _1password

      graphviz
      gprof2dot

      sqlite
      sqldiff
      # i3lock-color

      # Create .conf file in /etc/tmpfiles.d/ containing a symlink entry
      #     L+ /run/opengl-driver - - - - <nix-profile directory>
      #   Ensures drivers are symlinked nixos-style to make them accessible from
      #   nix-installed programs.
      mesa.drivers
      intel-media-driver

      bluetui

      pkgs.haskellPackages.ghcprofview
      # pkgs.haskellPackages.hpview
    ];
  };

  services = {
    random-background = {
      # enable = true;
      imageDirectory = "%h/Pictures/Wallpapers";
    };
  };

  programs = {
    git = {
      userName = "Curtis Chin Jen Sem";
      userEmail = "curtis.chinjensem@channable.com";
      extraConfig = {
        gpg.format = "ssh";
        user.signingkey = "/home/curtis/.ssh/id_ed25519.pub";
        commit.gpgsign = true;
      };
    };

    fish = {
      shellInitLast = ''
        begin
          set fish_greeting
          set __done_notify_sound 1

          # Non-NixOS setting
          set --export NIX_PATH $NIX_PATH:$HOME/.nix-defexpr/channels
          set --export NIXPKGS_ALLOW_UNFREE 1

          # Channable specific
          . ${inputs.channableFishFile}
        end
      '';
    };
  };
}
