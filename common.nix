{ config, pkgs, ... }:

let
  iosevka = pkgs.iosevka.override {
    set = "crtschin";
    privateBuildPlan = ''
    [buildPlans.iosevka-crtschin]
    family = "Iosevka crtschin"
    spacing = "normal"
    serifs = "sans"
    no-cv-ss = false
    export-glyph-names = true

      [buildPlans.iosevka-crtschin.variants]
      inherits = "ss05"

      [buildPlans.iosevka-crtschin.ligations]
      inherits = "dlig"
    '';
  };
in {
  imports = [
    ./home/i3.nix
    ./home/shell.nix
    ./home/services.nix
  ];

  systemd.user.startServices = "sd-switch";

  nixpkgs.config.allowUnfree = true;
  home = rec {
    packages = with pkgs; [
      fd
      jq
      arandr
      gitAndTools.git-absorb
      nitrogen
      pavucontrol
      playerctl
      ripgrep
      s-tui
      tig
      hyperfine
      du-dust
      xclip
      gitui
      ncdu
      niv
      any-nix-shell
      cachix

      direnv

      nix-direnv
      nix-tree
      nix-diff
      nvd

      betterlockscreen
      brave
      ffmpeg
      flameshot
      firefox
      fortune
      gimp
      imagemagick
      simplescreenrecorder
      spotify
      spotifyd
      texlive.combined.scheme-small
      vlc
      vscode
      rnix-lsp
      hivemind
      pipe-rename

      dejavu_fonts
      fira-code
      font-awesome
      source-serif-pro
      papirus-icon-theme
      gruvbox-dark-gtk
      gruvbox-dark-icons-gtk
    ];
  };

  fonts.fontconfig.enable = true;

  xdg = {
    enable = true;
    mime.enable = true;
    systemDirs.data = [ "/usr/share" "/usr/local/share" ];
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
          algorithm = "histogram";
          # Try to break up diffs at blank lines
          compactionHeuristic = true;
        };
        # For interactive rebases, automatically reorder and set the
        # right actions for !fixup and !squash commits.
        rebase.autosquash = true;
        # Include tags with commits that we push
        push.followTags = true;
        # Sort tags in version order, e.g. `v1 v2 .. v9 v10` instead
        # of `v1 v10 .. v9`
        tag.sort = "version:refname";
        # Remeber conflict resolutions. If the same conflict appears
        # again, use the previous resolution.
        rerere.enabled = true;
      };
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
        ''
      ;
    };
  };

  services = {
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
    EDITOR = "code";
    SHELL = "${pkgs.fish}/bin/fish";
    TERMINAL = "kitty";
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
    GIT_EDITOR = "${pkgs.vim}/bin/vim";
    NIXPKGS_ALLOW_INSECURE = 1;
  };
}
