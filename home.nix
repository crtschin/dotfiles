{ config, pkgs, ... }:

let
  lockCmd = "${pkgs.i3lock-fancy}/bin/i3lock-fancy -p -t ''";
in {
  imports = [
    ./home/i3.nix
    ./home/polybar.nix
    ./home/python.nix
    ./home/shell.nix
  ];

  nixpkgs.config.allowUnfree = true;
  home = {
    username = "crtschin";
    homeDirectory = "/home/crtschin";

    packages = with pkgs; [
      curl
      fd
      file
      git
      gtop
      htop
      pavucontrol
      playerctl
      ripgrep
      s-tui
      tig
      vim
      wget

      nix-tree

      alacritty
      ffmpeg
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
    ];
  };

  fonts.fontconfig.enable = true;

  programs = {
    home-manager = {
      enable = true;
    };

    firefox = {
      enable = true;
    };

    git = {
      enable = true;
      userName = "Curtis Chin Jen Sem";
      userEmail = "csochinjensem@gmail.com";
      delta.enable = true;
      lfs.enable = true;
      extraConfig = {
        core = {
          excludesfile = "${./.config/global.gitignore}";
        };
        merge = {
          conflictstyle = "diff3";
          difftool = "${pkgs.meld}/bin/meld";
        };
        delta = {
            features = "unobtrusive-line-numbers decorations";
            plus-style = "syntax \"#012800\"";
            minus-style = "syntax \"#340001\"";
            syntax-theme = "Monokai Extended";
        };
        "delta \"decorations\"" = {
            commit-decoration-style = "bold yellow box ul";
            file-style = "bold yellow ul";
            file-decoration-style = "none";
            hunk-header-decoration-style = "cyan box ul";
        };
        "delta \"unobtrusive-line-numbers\"" = {
            line-numbers = true;
            line-numbers-minus-style = "\"#666666\"";
            line-numbers-zero-style = "\"#444444\"";
            line-numbers-plus-style = "\"#aaaaaa\"";
            line-numbers-left-format = "\"{nm:>4}┊\"";
            line-numbers-right-format = "\"{np:>4}│\"";
            line-numbers-left-style = "blue";
            line-numbers-right-style = "blue";
        };
      };
    };
  };

  xsession = {
    enable = true;
  };

  services = {
    playerctld = {
      enable = true;
    };
    random-background = {
      enable = true;
      imageDirectory = "%h/backgrounds";
    };
    screen-locker = {
      enable = true;
      lockCmd = "${lockCmd}";
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
    EDITOR = "vim";
    TERMINAL = "kitty";
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };
}
