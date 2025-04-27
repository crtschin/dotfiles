{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./home/shell.nix
    ./home/services.nix
    ./home/modules/dunst.nix
    ./home/modules/fish.nix
    ./home/modules/ghostty.nix
    ./home/modules/git.nix
    ./home/modules/i3.nix
    ./home/modules/kanshi.nix
    ./home/modules/kitty.nix
    ./home/modules/polybar.nix
    ./home/modules/starship.nix
    ./home/modules/sway.nix
  ];

  systemd.user.startServices = "sd-switch";

  nixpkgs.config.allowUnfree = true;
  home = {
    packages = with pkgs; [
      # Desktop
      nitrogen

      # Sound
      pavucontrol
      playerctl

      # Utils
      fd
      jq
      ripgrep
      xclip
      direnv
      p7zip
      hivemind
      process-compose

      # Git
      gitAndTools.git-absorb
      difftastic
      tig
      gitui

      # System
      ncdu
      du-dust
      fastfetch
      brightnessctl

      # Debugging
      bpftrace

      # Benchmarking
      hyperfine

      # DNS
      dig

      # nix
      nil
      niv
      nixfmt-rfc-style
      any-nix-shell
      cachix
      nix-direnv
      nix-tree
      nix-diff
      nvd

      ffmpeg
      gimp
      imagemagick
      simplescreenrecorder

      # Programs
      spotify
      spotifyd
      vscode
      hivemind

      # Customization
      dejavu_fonts
      fira-code
      font-awesome
      source-code-pro
      papirus-icon-theme
      gruvbox-dark-gtk
      gruvbox-dark-icons-gtk
      pkgs.rice.font.monospace.package

      # Fun
      fortune
    ];
  };

  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;
    font = {
      package = pkgs.rice.font.monospace.package;
      name = pkgs.rice.font.monospace.name;
      size = 12;
    };
    theme = {
      name = "gruvbox-dark";
      package = pkgs.gruvbox-dark-gtk;
    };
    iconTheme = {
      name = "gruvbox-dark";
      package = pkgs.gruvbox-dark-icons-gtk;
    };
  };

  xdg = {
    enable = true;
    mime.enable = true;
    systemDirs.data = [
      "/usr/share"
      "/usr/local/share"
    ];

    configFile."direnv/direnvrc".text = ''
      source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
    '';
  };

  programs = {
    home-manager = {
      enable = true;
    };

    btop = {
      enable = true;
      settings = {
        color_theme = "gruvbox_dark";
        theme_background = false;
        truecolor = true;
      };
    };

    brave = {
      enable = true;
      # https://chromium.googlesource.com/chromium/src/+/refs/heads/main/docs/gpu/vaapi.md
      commandLineArgs = [
        "--use-gl=angle"
        "--use-angle=gl"
        "--ignore-gpu-blocklist"
        "--enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder"
      ];
    };

    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
      config = {
        hide_env_diff = true;
      };
    };

    firefox = {
      enable = true;
      package = pkgs.firefox;
    };

    man = {
      enable = true;
    };

    jqp = {
      enable = true;
      settings = {
        theme = "gruvbox";
      };
    };

    nix-your-shell = {
      enable = true;
    };

    taskwarrior = {
      enable = false;
    };

    gitui = {
      enable = false;
    };

    vim = {
      enable = true;
      extraConfig = ''
        syntax on
      '';
    };
  };

  services = {
    flameshot = {
      enable = true;
      package = pkgs.flameshot;
    };
    playerctld = {
      enable = true;
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
    XDG_SESSION_TYPE = "wayland";
    PAGER = "${pkgs.bat}/bin/bat -S";
    MANPAGER = "${pkgs.bat}/bin/bat -S -l man";
    EDITOR = "${pkgs.vscode}/bin/code";
    TERMINAL = "${pkgs.kitty}/bin/kitty";
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
    GIT_EDITOR = "${pkgs.vim}/bin/vim";
    NIXPKGS_ALLOW_INSECURE = 1;
  };
}
