F{ config, lib, pkgs, ... }:

let
  pisces = pkgs.fishPlugins.buildFishPlugin rec {
    pname = "pisces";
    version = "0.7.0";

    src = pkgs.fetchFromGitHub {
      owner = "laughedelic";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-Oou2IeNNAqR00ZT3bss/DbhrJjGeMsn9dBBYhgdafBw=";
    };
  };
  devFishPlugins = with pkgs.fishPlugins; [
    done
    foreign-env
    fzf-fish
    pisces
  ];
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
      config = {
        theme = "gruvbox-dark";
      };
      themes = {
        gruvbox = builtins.readFile (pkgs.fetchFromGitHub {
          owner = "subnut";
          repo = "gruvbox-tmTheme"; # Bat uses sublime syntax for its themes
          rev = "64c47250e54298b91e2cf8d401320009aba9f991";
          sha256 = "1kh0230maqvzynxxzv813bdgpcs1sh13cw1jw6piq6kigwbaw3kb";
        } + "/gruvbox-dark.tmTheme");
      };
    };

    broot = {
      enable = true;
      enableFishIntegration = true;
      skin = {
        default = "rgb(235, 219, 178) none / rgb(189, 174, 147) none";
        tree = "rgb(168, 153, 132) None / rgb(102, 92, 84) None";
        parent = "rgb(235, 219, 178) none / rgb(189, 174, 147) none Italic";
        file = "None None / None  None Italic";
        directory = "rgb(131, 165, 152) None Bold / rgb(131, 165, 152) None";
        exe = "rgb(184, 187, 38) None";
        link = "rgb(104, 157, 106) None";
        pruning = "rgb(124, 111, 100) None Italic";
        perm__ = "None None";
        perm_r = "rgb(215, 153, 33) None";
        perm_w = "rgb(204, 36, 29) None";
        perm_x = "rgb(152, 151, 26) None";
        owner = "rgb(215, 153, 33) None Bold";
        group = "rgb(215, 153, 33) None";
        count = "rgb(69, 133, 136) rgb(50, 48, 47)";
        dates = "rgb(168, 153, 132) None";
        sparse = "rgb(250, 189,47) None";
        content_extract = "ansi(29) None Italic";
        content_match = "ansi(34) None Bold";
        git_branch = "rgb(251, 241, 199) None";
        git_insertions = "rgb(152, 151, 26) None";
        git_deletions = "rgb(190, 15, 23) None";
        git_status_current = "rgb(60, 56, 54) None";
        git_status_modified = "rgb(152, 151, 26) None";
        git_status_new = "rgb(104, 187, 38) None Bold";
        git_status_ignored = "rgb(213, 196, 161) None";
        git_status_conflicted = "rgb(204, 36, 29) None";
        git_status_other = "rgb(204, 36, 29) None";
        selected_line = "None rgb(60, 56, 54) / None rgb(50, 48, 47)";
        char_match = "rgb(250, 189, 47) None";
        file_error = "rgb(251, 73, 52) None";
        flag_label = "rgb(189, 174, 147) None";
        flag_value = "rgb(211, 134, 155) None Bold";
        input = "rgb(251, 241, 199) None / rgb(189, 174, 147) None Italic";
        status_error = "rgb(213, 196, 161) rgb(204, 36, 29)";
        status_job = "rgb(250, 189, 47) rgb(60, 56, 54)";
        status_normal = "None rgb(40, 38, 37) / None None";
        status_italic = "rgb(211, 134, 155) rgb(40, 38, 37) Italic / None None";
        status_bold = "rgb(211, 134, 155) rgb(40, 38, 37) Bold / None None";
        status_code = "rgb(251, 241, 199) rgb(40, 38, 37) / None None";
        status_ellipsis = "rgb(251, 241, 199) rgb(40, 38, 37)  Bold / None None";
        purpose_normal = "None None";
        purpose_italic = "rgb(177, 98, 134) None Italic";
        purpose_bold = "rgb(177, 98, 134) None Bold";
        purpose_ellipsis = "None None";
        scrollbar_track = "rgb(80, 73, 69) None / rgb(50, 48, 47) None";
        scrollbar_thumb = "rgb(213, 196, 161) None / rgb(102, 92, 84) None";
        help_paragraph = "None None";
        help_bold = "rgb(214, 93, 14) None Bold";
        help_italic = "rgb(211, 134, 155) None Italic";
        help_code = "rgb(142, 192, 124) rgb(50, 48, 47)";
        help_headers = "rgb(254, 128, 25) None Bold";
        help_table_border = "rgb(80, 73, 69) None";
        preview_title = "rgb(235, 219, 178) rgb(40, 40, 40) / rgb(189, 174, 147) rgb(40, 40, 40)";
        preview = "rgb(235, 219, 178) rgb(40, 40, 40) / rgb(235, 219, 178) rgb(40, 40, 40)";
        preview_line_number = "rgb(124, 111, 100) None / rgb(124, 111, 100) rgb(40, 40, 40)";
        preview_match = "None ansi(29) Bold";
        hex_null = "rgb(189, 174, 147) None";
        hex_ascii_graphic = "rgb(213, 196, 161) None";
        hex_ascii_whitespace = "rgb(152, 151, 26) None";
        hex_ascii_other = "rgb(254, 128, 25) None";
        hex_non_ascii = "rgb(214, 93, 14) None";
        staging_area_title = "rgb(235, 219, 178) rgb(40, 40, 40) / rgb(189, 174, 147) rgb(40, 40, 40)";
        mode_command_mark = "gray(5) ansi(204) Bold";
      };
    };

    exa = {
      enable = true;
      enableAliases = true;
    };

    fish = {
      interactiveShellInit = ''
        begin
          set fish_greeting
          set __done_notify_sound 1
        end
        ''
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
        {
          name = "bass";
          src = pkgs.fetchFromGitHub {
            owner = "edc";
            repo = "bass";
            rev = "2fd3d2157d5271ca3575b13daec975ca4c10577a";
            sha256 = "0mb01y1d0g8ilsr5m8a71j6xmqlyhf8w4xjf00wkk8k41cz3ypky";
          };

        }
      ];
    };

    autojump = {
      enable = true;
    };

    fzf = {
      enable = true;
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
        "ctrl+equal" = "change_font_size all +2.0";
        "ctrl+minus" = "change_font_size all -2.0";
      };
    };

    alacritty = {
      enable = true;
      settings = {
        colors = {
          primary = {
            background = "0x282828";
            foreground = "0xdfbf8e";
          };
          normal = {
            black   = "0x665c54";
            red     = "0xea6962";
            green   = "0xa9b665";
            yellow  = "0xe78a4e";
            blue    = "0x7daea3";
            magenta = "0xd3869b";
            cyan    = "0x89b482";
            white   = "0xdfbf8e";
          };
          bright = {
            black   = "0x928374";
            red     = "0xea6962";
            green   = "0xa9b665";
            yellow  = "0xe3a84e";
            blue    = "0x7daea3";
            magenta = "0xd3869b";
            cyan    = "0x89b482";
            white   = "0xdfbf8e";
          };
        };
        font = {
          normal.family = "Fira Code";
          normal.style = "Regular";
          bold.family = "Fira Code";
          bold.style = "Bold";
          italic.family = "Fira Code";
          italic.style = "Light Italic";
          size = 13;
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
          args = [ "--command=${pkgs.tmux}/bin/tmux" ];
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
          display = [{
            threshold = 45;
            style = "bold yellow";
            discharging_symbol = "💦";
          } {
            threshold = 10;
            style = "bold red";
            discharging_symbol = "💀";
          }];
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

        env_var = {
          IN_NIX = {
            default = "";
            format = "[$env_value]($style)";
            style = "bold blue";
          };
        };

        git_branch = {
          format = "\\[[$symbol$branch]($style)\\]";
          symbol = "🌱";
          truncation_length = 13;
          ignore_branches = ["master"];
          style = "bold yellow";
        };

        git_commit = {
          commit_hash_length = 6;
          tag_disabled = false;
          tag_symbol = "🔖";
          style = "bright-white";
          format = "[\\[$hash$tag\\]]($style)";
        };

        git_status = {
          conflicted = "⚔️";
          ahead = "🏎️💨";
          behind = "🐢";
          diverged = "😵🏎️💨*$ahead_count🐢*$behind_count";
          untracked = "🛤️";
          stashed = "📦";
          modified = "📝";
          staged = "🗃️";
          renamed = "📛";
          deleted = "🗑️";
          style = "bright-white";
          format = "(\\[$all_status$ahead_behind\\])($style)";
        };

        haskell = {
          symbol = "λ";
          format = "\\[[$symbol($ghc_version)]($style)\\]";
        };

        hostname = {
          ssh_only = false;
          format = "<[$hostname]($style)>";
          trim_at = "-";
          style = "bold dimmed white";
          disabled = true;
        };

        memory_usage = {
          symbol = "🐏";
          format = "\\[$symbol[$ram(|$swap)]($style)\\]";
          threshold = 0;
          style = "bold dimmed white";
          disabled = false;
        };

        package = {
          disabled = false;
        };

        python = {
          symbol = "🐍";
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
          symbol = "↕️";
          format = "\\[[$symbol$shlvl]($style)\\] ";
          threshold = 3;
        };
      };
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
        ''
      ;
    };
  };
}
