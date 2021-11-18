{ config, pkgs, ... }:

{
  nixpkgs.overlays = [ (self: super: {
    nix_gl = (import (fetchGit {
      ref = "main";
      url = "https://github.com/guibou/nixGL.git";
    }) {}).auto.nixGLDefault;

    nix_gl_wrapper = program: pkgs.writeShellScriptBin program.pname ''
      ${self.nix_gl}/bin/nixGL ${program}/bin/${program.pname} "$@"
    '';

    # Usage notice, install wrapped packages in `/usr/bin`
    native_wrapper = program: pkgs.writeShellScriptBin program.pname ''
      PATH=/usr/bin:${program}/bin ${program.pname} "$@"
    '';

    betterlockscreen = self.native_wrapper super.betterlockscreen;
    i3lock = self.native_wrapper super.i3lock-color;

    kitty = self.nix_gl_wrapper super.kitty;
    alacritty = pkgs.nix_gl_wrapper super.alacritty;
    picom = pkgs.nix_gl_wrapper super.picom;
  }) ];

  imports = [
    ./common.nix
  ];

  targets.genericLinux.enable = true;

  home = rec {
    username = "curtis";
    homeDirectory = "/home/${username}";
    packages = with pkgs; [ ];
  };

  services = {
    random-background = {
      enable = false;
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
