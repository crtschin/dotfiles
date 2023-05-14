{
  config,
  lib,
  pkgs,
  ...
}: let
in {
  home.packages = with pkgs; [
    exa
  ];

  programs = {
    autorandr = {
      enable = true;
    };

    bat = {
      enable = true;
      config = {
        theme = "gruvbox-dark";
      };
      themes = {
        gruvbox = builtins.readFile (pkgs.fetchFromGitHub {
            owner = "subnut";
            repo = "gruvbox-tmTheme"; # Bat uses sublime syntax for its themes
            rev = "64c47250e54298b91e2cf8d401320009aba9f991";
            sha256 = "1kh0230maqvzynxxzv813bdgpcs1sh13cw1jw6piq6kigwbaw3kb";
          }
          + "/gruvbox-dark.tmTheme");
      };
    };

    broot = {
      enable = true;
      settings = {
        modal = true;
        verbs = [
          {
            invocation = "edit";
            shortcut = "e";
            key = "enter";
            execution = "$EDITOR {file}";
            leave_broot = false;
            apply_to = "file";
          }
          {
            invocation = "view";
            shortcut = "v";
            execution = "bat {file}";
          }
          {
            invocation = "parent";
            shortcut = "p";
            execution = ":parent";
          }
          # { invocation = "text"; execution = "preview_text"; }
          # { invocation = "binary"; execution = "preview_binary"; }
          # { invocation = "image"; execution = "preview_image"; }
        ];
        default_flags = "gh";
        quit_on_last_cancel = true;
        imports = [
          {
            file = "dark-gruvbox.hjson";
            luma = ["dark" "unknown"];
          }
        ];
      };
    };

    exa = {
      enable = true;
      enableAliases = true;
    };

    autojump = {
      enable = true;
    };

    fzf = {
      enable = true;
    };

    tmux = {
      enable = true;
      clock24 = true;
      historyLimit = 5000;
      prefix = "C-Space";
      extraConfig = ''
        bind-key -n C-t new-window
        bind-key -n C-w kill-window
        bind-key -n C-Up previous-window
        bind-key -n C-Down next-window
        bind-key -n C-x kill-pane
        bind-key -n C-n split-window -v
        bind-key -n C-M-n split-window -h
        bind-key -n M-Up select-pane -U
        bind-key -n M-Down select-pane -D
        bind-key -n M-Left select-pane -L
        bind-key -n M-Right select-pane -R

        bind -n M-s setw synchronize-panes

        # Prevent vim from swallowing ctrl arrows
        set-window-option -g xterm-keys on

        # Use the screen-256color terminal
        set -g default-terminal \"screen-256color\"

        # Apply Tc
        set-option -ga terminal-overrides \",screen-256color:Tc\"
        set -g mouse on
        set -g focus-events on
      '';
    };
  };
}
