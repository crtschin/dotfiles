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
    ./home/modules/helix.nix
    ./home/modules/kanshi.nix
    ./home/modules/kitty.nix
    ./home/modules/starship.nix
    ./home/modules/sway.nix
    ./home/modules/vim.nix
    ./home/modules/waybar.nix
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
      fx
      jc
      ripgrep
      xclip
      direnv
      p7zip
      hivemind
      process-compose
      jump
      bluetui
      jujutsu

      # Git
      git-absorb
      difftastic

      # System
      ncdu
      dust
      fastfetch
      brightnessctl

      # File Manager
      yazi

      # Debugging
      # bpftrace
      xxd

      # Benchmarking
      hyperfine

      # DNS
      dig

      # nix
      nixd
      niv
      nixfmt-rfc-style
      any-nix-shell
      cachix
      nix-direnv
      nix-tree
      nix-diff
      nvd
      nix-output-monitor

      ffmpeg
      gimp
      imagemagick
      obs-studio
      mupdf
      qrencode

      # Programs
      vscode
      hivemind
      zoom-us
      spotify

      # Customization
      dejavu_fonts
      fira-code
      font-awesome
      source-code-pro

      # Keyboard
      via
      vial
      qmk
      ttyper

      # papirus-icon-theme
      gruvbox-dark-gtk
      gruvbox-dark-icons-gtk
      pkgs.rice.font.normal.package
      pkgs.rice.font.monospace.package

      # Fun
      fortune
    ];
  };

  fonts.fontconfig = {
    enable = true;
    antialiasing = true;
    hinting = "slight";
    subpixelRendering = "rgb";
  };

  gtk = {
    enable = true;
    font = {
      package = pkgs.rice.font.normal.package;
      name = pkgs.rice.font.normal.name;
      size = pkgs.rice.font.normal.size;
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
      # "/usr/share"
      # "/usr/local/share"
    ];
    portal = {
      enable = true;
      config = {
        sway = {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
          "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
        };
      };
      extraPortals = with pkgs; [
        kdePackages.xdg-desktop-portal-kde
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
    };
    configFile."direnv/direnvrc".text = ''
      source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
    '';
  };

  programs = {
    home-manager = {
      enable = true;
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

    btop = {
      enable = true;
      settings = {
        color_theme = "gruvbox_dark";
        theme_background = false;
        truecolor = true;
      };
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

    jjui = {
      enable = true;
    };

    jqp = {
      enable = true;
      settings = {
        theme = "gruvbox";
      };
    };

    lazydocker = {
      enable = true;
    };

    lazygit = {
      enable = true;
    };

    lazysql = {
      enable = true;
    };

    man = {
      enable = true;
    };

    nix-search-tv = {
      enable = true;
    };

    pgcli = {
      enable = true;
      settings = {
        main = {
          destructive_statements_require_transaction = true;
          smart_completion = true;
          multi_line = true;
          auto_expand = true;
          destructive_warning = true;
        };
        colors = {
          "Token.Menu.Completions.Completion.Current" = "bg:#ffffff #000000";
          "Token.Menu.Completions.Completion" = "bg:#008888 #ffffff";
          "Token.Menu.Completions.Meta.Current" = "bg:#44aaaa #000000";
          "Token.Menu.Completions.Meta" = "bg:#448888 #ffffff";
          "Token.Menu.Completions.MultiColumnMeta" = "bg:#aaffff #000000";
          "Token.Menu.Completions.ProgressButton" = "bg:#003333";
          "Token.Menu.Completions.ProgressBar" = "bg:#00aaaa";
          "Token.SelectedText" = "#ffffff bg:#6666aa";
          "Token.SearchMatch" = "#ffffff bg:#4444aa";
          "Token.SearchMatch.Current" = "#ffffff bg:#44aa44";
          "Token.Toolbar" = "bg:#222222 #aaaaaa";
          "Token.Toolbar.Off" = "bg:#222222 #888888";
          "Token.Toolbar.On" = "bg:#222222 #ffffff";
          "Token.Toolbar.Search" = "noinherit bold";
          "Token.Toolbar.Search.Text" = "nobold";
          "Token.Toolbar.System" = "noinherit bold";
          "Token.Toolbar.Arg" = "noinherit bold";
          "Token.Toolbar.Arg.Text" = "nobold";
          "Token.Toolbar.Transaction.Valid" = "bg:#222222 #00ff5f bold";
          "Token.Toolbar.Transaction.Failed" = "bg:#222222 #ff005f bold";
        };
      };
    };

    sioyek = {
      enable = true;
    };

    swappy = {
      enable = true;
    };

    taskwarrior = {
      enable = false;
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
    TERMINAL = pkgs.configuration.variables.terminal;
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
    GIT_EDITOR = "${pkgs.helix}/bin/hx";
    NIXPKGS_ALLOW_INSECURE = 1;
    GTK_USE_PORTAL = 1;
  };
}
