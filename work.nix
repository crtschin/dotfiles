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

    native_wrapper = program: pkgs.writeShellScriptBin program.pname ''
      PATH=/usr/bin:${program}/bin ${program.pname} "$@"
    '';

    # On Ubuntu:
    #   install betterlockscreen in /usr/bin
    #   install i3lock in /usr/bin
    hello = pkgs.writeShellScriptBin "hello" ''
      echo "Hello world"
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
      promptInit =
        ''
begin
  set fish_greeting
  set __done_notify_sound 1
  set LESS ' -R '

  # Non-NixOS setting
  set --export NIX_PATH $NIX_PATH:$HOME/.nix-defexpr/channels

  # Channable specific
  . ${.config/channable.fish}
end

alias l "exa"
alias ll "exa -la"
alias ls "exa"
alias less "bat"
alias g "git"
alias e "eval $EDITOR"
alias ee "e (fzf)"
        ''
      ;
    };
  };
}
