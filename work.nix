{ config, pkgs, ... }:

{
  nixpkgs.overlays = [ (self: super: {
    nix_gl = (import (fetchGit {
      ref = "28432f4703506e0e019a60fdc2859717e2344eae";
      url = "https://github.com/cathaysia/nixGL.git";
    }) {}).auto.nixGLDefault;

    nix_gl_wrapper = program: pkgs.writeShellScriptBin program.pname ''
      exec ${self.nix_gl}/bin/nixGL ${program}/bin/${program.pname} "$@"
    '';

    # Usage notice, install wrapped packages in `/usr/bin`
    native_wrapper = program: pkgs.writeShellScriptBin program.pname ''
      PATH=/usr/bin:${program}/bin ${program.pname} "$@"
    '';

    monitor-heap = pkgs.writeShellScriptBin "monitor-heap" ''
    #!/bin/sh
    head -`fgrep -n END_SAMPLE $1.hp | tail -1 | cut -d : -f 1` $1.hp \
      | hp2ps > $1.ps
    gv $1.ps &
    gvpsnum=$!
    while [ 1 ] ; do
      sleep 10
      head -`fgrep -n END_SAMPLE $1.hp | tail -1 | cut -d : -f 1` $1.hp \
        | hp2ps > $1.ps
      kill -HUP $gvpsnum
    done
    '';

    mermaid-cli = pkgs.writeScriptBin "mmdc" ''
      #!${pkgs.stdenv.shell}
      exec ${pkgs.nodePackages.mermaid-cli}/bin/mmdc \
      "$@"
    '';

    betterlockscreen = self.native_wrapper super.betterlockscreen;
    i3lock = self.native_wrapper super.i3lock-color;

    brave = self.nix_gl_wrapper super.brave;
    kitty = self.nix_gl_wrapper super.kitty;
    alacritty = self.nix_gl_wrapper super.alacritty;
    picom = self.nix_gl_wrapper super.picom;
  }) ];

  imports = [
    ./common.nix
  ];

  targets.genericLinux.enable = true;

  home = rec {
    username = "curtis";
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      gv
      monitor-heap
      mermaid-cli
      pgadmin
    ];
  };

  services = {
    random-background = {
      enable = true;
      imageDirectory = "%h/Pictures/Wallpapers";
    };
  };

  programs = {
    git = {
      userName = "Curtis Chin Jen Sem";
      userEmail = "curtis.chinjensem@channable.com";
    };

    fish = {
      interactiveShellInit = ''
        begin
          set fish_greeting
          set __done_notify_sound 1
          set LESS ' -R '

          # Non-NixOS setting
          set --export NIX_PATH $NIX_PATH:$HOME/.nix-defexpr/channels
          set --export NIXPKGS_ALLOW_UNFREE 1

          # Channable specific
          . ${.config/channable.fish}
        end

        fzf_configure_bindings --git_status=\a
        ''
      ;
    };
  };
}
