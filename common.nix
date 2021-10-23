{ config, pkgs, ... }:

let

in {
  imports = [
    ./home/i3.nix
    ./home/python.nix
    ./home/shell.nix
  ];

  systemd.user.startServices = "sd-switch";

  xdg.systemDirs.data = [ "/usr/share" "/usr/local/share" ];
  nixpkgs.config.allowUnfree = true;
  home = rec {
    packages = with pkgs; [
      arandr
      curl
      fd
      feh
      file
      git
      gtop
      htop
      nitrogen
      pavucontrol
      playerctl
      ripgrep
      s-tui
      tig
      wget

      nix-tree

      betterlockscreen
      ffmpeg
      flameshot
      firefox
      fortune
      gimp
      imagemagick
      simplescreenrecorder
      spotify
      spotifyd
      texlive.combined.scheme-basic
      vlc
      vscode

      gcc
      python
      rustc
      rustfmt
      cargo

      dejavu_fonts
      fira-code
      fira-code-symbols
      font-awesome
      source-serif-pro
      papirus-icon-theme
      gruvbox-dark-gtk
      gruvbox-dark-icons-gtk

    ];
  };

  fonts.fontconfig.enable = true;

  programs = {
    home-manager = {
      enable = true;
    };

    firefox = {
      enable = true;
      package = pkgs.firefox;
    };

    git = {
      enable = true;
      delta = {
        enable = true;
      };
      lfs.enable = true;
      extraConfig = {
        pager = {
          diff = "delta";
          log = "delta";
          reflog = "delta";
          show = "delta";
        };
        core = {
          editor = "${pkgs.vim}/bin/vim";
          excludesfile = "${./.config/global.gitignore}";
        };
        merge = {
          conflictstyle = "diff3";
          difftool = "${pkgs.meld}/bin/meld";
        };
        delta = {
            features = "interactive unobtrusive-line-numbers decorations";
            syntax-theme = "gruvbox-dark";
        };
      };
    };

    vim = {
      enable = true;
      extraConfig =
        ''
syntax on
        ''
      ;
    };
  };

  services = {
    playerctld = {
      enable = true;
    };
    random-background = {
      imageDirectory = "%h/backgrounds";
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";

  home.sessionVariables = {
    EDITOR = "vscode";
    TERMINAL = "kitty";
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };
}
