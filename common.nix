{
  lib,
  config,
  pkgs,
  ...
}:
let
in
{
  nixpkgs.overlays = [ (import ./home/overlays/rice.nix) ];

  imports = [
    ./home/wm.nix
    ./home/shell.nix
    ./home/services.nix
    ./home/modules/fish.nix
    ./home/modules/dunst.nix
    ./home/modules/ghostty.nix
    ./home/modules/kanshi.nix
    ./home/modules/kitty.nix
    ./home/modules/polybar.nix
    ./home/modules/starship.nix
  ];

  systemd.user.startServices = "sd-switch";

  nixpkgs.config.allowUnfree = true;
  home = rec {
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

    autorandr = {
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

    git = {
      enable = true;
      lfs.enable = true;
      delta.enable = true;
      # Prevent bad objects from spreading.
      # transfer.fsckObjects = true;
      extraConfig = {
        alias = {
          lc = "!fish -c 'git checkout (git branch --list --sort=-committerdate | string trim | fzf --preview=\"git log --stat -n 10 --decorate --color=always {}\")'";
          oc = "!fish -c 'git checkout (git for-each-ref refs/remotes/origin/ --format=\"%(refname:short)\" --sort=-committerdate|perl -p -e \"s#^origin/##g\"|head -100|string trim|fzf --preview=\"git log --stat -n 10 --decorate --color=always origin/{}\")'";
        };
        # blame.ignoreRevsFile = ".git-blame-ignore-revs";
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
        diff = {
          external = "difft";
          algorithm = "histogram";
          # Try to break up diffs at blank lines
          compactionHeuristic = true;
          colorMoved = "dimmed_zebra";
        };
        # For interactive rebases, automatically reorder and set the
        # right actions for !fixup and !squash commits.
        rebase = {
          autosquash = true;
          updateRefs = true;
        };
        # Include tags with commits that we push
        push = {
          followTags = true;
          autoSetupRemote = true;
        };
        # Sort tags in version order, e.g. `v1 v2 .. v9 v10` instead
        # of `v1 v10 .. v9`
        tag.sort = "version:refname";
        # Remeber conflict resolutions. If the same conflict appears
        # again, use the previous resolution.
        rerere.enabled = true;
      };
    };

    man = {
      enable = true;
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
    playerctld = {
      enable = true;
    };
    # autorandr = {
    #   enable = true;
    #   ignoreLid = true;
    # };
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
