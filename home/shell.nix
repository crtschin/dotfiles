{ config, lib, pkgs, ... }:

let
  shellAliases = {
    l = "exa";
    ll = "exa -la";
    ls = "exa";
    less = "bat";
    g = "git";
    e = "eval $EDITOR";
    ee = "e (fzf)";
    lock = "${pkgs.i3lock-fancy}/bin/i3lock-fancy -p -t ''";
  };
  devFishPlugins = with pkgs.fishPlugins; [
    done
    foreign-env
    fzf-fish
    pisces
  ];

  tmuxConfig = {
    enable = true;
    clock24 = true;
    historyLimit = 5000;
    prefix = "C-Space";
    extraConfig =
      "
bind-key -n C-t new-window
bind-key -n C-w kill-window
bind-key -n C-Up previous-window
bind-key -n C-Down next-window
bind-key -n M-Up select-pane -U
bind-key -n M-Down select-pane -D
bind-key -n M-Left select-pane -L
bind-key -n M-Right select-pane -R

bind -n M-s setw synchronize-panes

# Prevent vim from swallowing ctrl arrows
set-window-option -g xterm-keys on

# Use the xterm-256color terminal
set -g default-terminal \"screen-256color\"

# Apply Tc
set-option -ga terminal-overrides \",screen-256color:Tc\"
set -g mouse on
set -g focus-events on
      "
    ;
  };
in
{
  home.packages = with pkgs; [
    exa
  ] ++ devFishPlugins;

  programs = {
    autorandr = {
      enable = true;
    };

    bat = {
      enable = true;
    };

    broot = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };

    exa = {
      enable = true;
    };

    fish = {
      inherit shellAliases;
      promptInit =
        "
        begin
          set fish_greeting
          set __done_notify_sound 1
          set LESS ' -R '
        end
        "
      ;
      functions = {
        giffify = {
          body = "ffmpeg -i $video_file -r 15 -vf \"scale=1024:-1,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse\" $giff_name.gif";
          description = "giffify <video_file> <gif_name>";
          argumentNames = ["video_file" "gif_name"];
        };
      };
      enable = true;
      plugins = [
        {
          name = "z";
          src = pkgs.fetchFromGitHub {
            owner = "jethrokuan";
            repo = "z";
            rev = "e0e1b9dfdba362f8ab1ae8c1afc7ccf62b89f7eb";
            sha256 = "0dbnir6jbwjpjalz14snzd3cgdysgcs3raznsijd6savad3qhijc";
          };
        }
      ];
    };

    autojump = {
      enable = true;
    };

    bash = {
      enable = true;
      historyIgnore = [ "l" "ls" "cd" "exit" ];
      historyControl = [ "erasedups" ];
      inherit shellAliases;
      initExtra =
        ''
if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
  . ~/.nix-profile/etc/profile.d/nix.sh;
  export NIX_PATH=$HOME/.nix-defexpr/channels''${NIX_PATH:+:}$NIX_PATH
fi # added by Nix installer
        ''
      ;
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };

    kitty = {
      enable = true;
      font = {
        name = "Fira Code";
        size = 14;
      };
      settings = {
        disable_ligatures = "cursor";
        scrollback_lines = 10000;
        copy_on_select = true;
        strip_trailing_spaces = "always";
        cursor_shape = "block";
        enable_audio_bell = true;
        visual_bell_duration = "0.5";
        shell = "${pkgs.fish}/bin/fish";
        # GruvboxMaterial theme by sainnhe
        # License: [MIT License](https://opensource.org/licenses/MIT).
        background = "#32302f";
        foreground = "#dfbf8e";
        selection_background = "#dfbf8e";
        selection_foreground = "#32302f";
        active_tab_background = "#32302f";
        active_tab_foreground = "#dfbf8e";
        active_tab_font_style = "bold-italic";
        inactive_tab_background = "#32302f";
        inactive_tab_foreground = "#a89984";
        inactive_tab_font_style = "normal";
        # Black
        color0 = "#665c54";
        color8 = "#928374";
        # Red
        color1 = "#ea6962";
        color9 = "#ea6962";
        # Green
        color2 = "#a9b665";
        color10 = "#a9b665";
        # Yellow
        color3 = "#e78a4e";
        color11 = "#e3a84e";
        # Blue
        color4 = "#7daea3";
        color12 = "#7daea3";
        # Magenta
        color5 = "#d3869b";
        color13 = "#d3869b";
        # Cyan
        color6 = "#89b482";
        color14 = "#89b482";
        # White
        color7  = "#dfbf8e";
        color15 = "#dfbf8e";
        clear_all_shortcuts = true;
      };
      keybindings = {
        "ctrl+c" = "copy_or_interrupt";
        "ctrl+shift+c" = "copy_to_clipboard";
        "ctrl+shift+v" = "paste_from_clipboard";
        "shift+insert" = "paste_from_clipboard";
        "ctrl+s" = "paste_from_selection";

        "alt+up" = "scroll_line_up";
        "alt+down" = "scroll_line_down";
        "alt+page_up" = "scroll_page_up";
        "alt+page_down" = "scroll_page_down";
        "alt+home" = "scroll_home";
        "alt+end" = "scroll_end";
        "alt+h" = "show_scrollback";

        "ctrl+up" = "next_tab";
        "ctrl+down" = "previous_tab";
        "ctrl+t" = "new_tab";
        "ctrl+w" = "close_tab";
        "ctrl+n" = "new_window";
        "ctrl+x" = "close_window";
        "ctrl+right" = "next_window";
        "ctrl+left" = "previous_window";
      };
    };

    alacritty = {
      enable = true;
      settings = {
        colors = {
          primary = {
            background = "0x282828";
            foreground = "0xebdbb2";
          };
          normal = {
            black   = "0x282828";
            red     = "0xcc241d";
            green   = "0x98971a";
            yellow  = "0xd79921";
            blue    = "0x458588";
            magenta = "0xb16286";
            cyan    = "0x689d6a";
            white   = "0xa89984";
          };
          bright = {
            black   = "0x928374";
            red     = "0xfb4934";
            green   = "0xb8bb26";
            yellow  = "0xfabd2f";
            blue    = "0x83a598";
            magenta = "0xd3869b";
            cyan    = "0x8ec07c";
            white   = "0xebdbb2";
          };
        };
        font = {
          normal.family = "Fira Code";
          normal.style = "Retina";
          bold.family = "Fira Code";
          bold.style = "Medium";
          italic.family = "Fira Code";
          italic.style = "Light Italic";
        };
        mouse = {
          double_click = { threshold = 300; };
          triple_click = { threshold = 300; };
          hide_when_typing = true;
        };
        selection = {
          semantic_escape_chars = ",│`|:\"' ()[]{}<>";
          save_to_clipboard = false;
        };
        mouse_bindings = [{ mouse = "Middle"; action = "PasteSelection"; }];
        cursor = {
          style = "Block";
          unfocused_hollow = true;
        };
        shell = {
          program = "${pkgs.fish}/bin/fish";
        };
      };
    };

    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        # add_newline = false

        aws = {
          disabled = true;
        };

        gcloud = {
          format = "on [$symbol($region)]($style) ";
          disabled = true;
        };

        # line_break = {
        #   disabled = true;
        # };

        battery = {
          full_symbol = "🔋";
          charging_symbol = "🔌";
          discharging_symbol = "⚡";
          display = {
            threshold = 45;
            style = "bold red";
          };
        };

        character = {
          error_symbol = "[✖](bold red)";
        };

        cmd_duration = {
          min_time = 10000;
          format = " took [$duration]($style)";
        };

        directory = {
          truncation_length = 5;
          truncation_symbol = "…/";
          format = "[$path]($style)[$lock_symbol]($lock_style) with ";
        };

        git_branch = {
          format = "\\[[$symbol$branch]($style)\\]";
          symbol = "🌱 ";
          style = "bold yellow";
        };

        git_commit = {
          commit_hash_length = 6;
          tag_disabled = false;
          style = "bold white";
        };

        git_status = {
          conflicted = "⚔️";
          ahead = "🏎️💨 ";
          behind = "🐢";
          diverged = "😵 🏎️💨  *$ahead_count 🐢 *$behind_count";
          untracked = "🛤️ ";
          stashed = "📦 ";
          modified = "📝";
          staged = "🗃️ ";
          renamed = "📛 ";
          deleted = "🗑️ ";
          style = "bright-white";
          format = "(\\[$all_status$ahead_behind\\])($style)";
        };

        hostname = {
          ssh_only = false;
          format = "<[$hostname]($style)>";
          trim_at = "-";
          style = "bold dimmed white";
          disabled = true;
        };

        memory_usage = {
          format = "\\[$symbol[$ram(|$swap)]($style)\\]";
          threshold = 0;
          style = "bold dimmed white";
          disabled = false;
        };

        package = {
          disabled = false;
        };

        python = {
          symbol = "🐍 ";
          format = "\\[[$symbol$pyenv_prefix($version)(\($virtualenv\))]($style)\\]";
          disabled = true;
        };

        rust = {
          format = "\\[[$symbol$version]($style)\\]";
          style = "bold green";
        };

        status = {
          format = "\\[[$symbol$status]($style)\\]";
          disabled = true;
        };

        nix_shell = {
          impure_msg = "[impure](bold red)";
          pure_msg = "[pure](bold green)";
        };

        time = {
          time_format = "%T";
          format = "\\[🕙 $time($style)\\]";
          style = "bright-white";
          disabled = true;
        };

        username = {
          style_user = "bold blue";
          format = "[$user]($style) in ";
          show_always = false;
        };

        vagrant = {
          disabled = true;
        };

        shlvl = {
          disabled = false;
          symbol = "↕️ ";
          format = "\\[[$symbol$shlvl]($style)\\] ";
          threshold = 2;
        };
      };
    };
    # tmux = tmuxConfig;
  };
}
