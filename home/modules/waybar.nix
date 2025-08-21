{
  config,
  lib,
  pkgs,
  ...
}:
let
  rgbTheme = pkgs.riceExtendedColorPalette;
in
{
  programs = {
    waybar = {
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 15;
          output = [
            "*"
          ];
          modules-left = [
            "sway/workspaces"
            # "wlr/taskbar"
          ];
          modules-center = [
            "mpris"
            "custom/separator"
            "sway/window"
          ];
          modules-right = [
            "clock"
            "custom/separator"
            "pulseaudio"
            "custom/separator"
            "cpu"
            "memory"
            "custom/separator"
            "upower"
          ];
          pulseaudio = {
            format = "{volume}% {icon}";
            format-bluetooth = "{volume}% {icon} ";
            format-muted = "";
            format-icons = {
              "alsa_output.pci-0000_00_1f.3.analog-stereo" = "";
              "alsa_output.pci-0000_00_1f.3.analog-stereo-muted" = "";
              "headphone" = "";
              "headset" = "";
              "phone" = "";
              "phone-muted" = "";
              "default" = [
                ""
                ""
              ];
            };
            "scroll-step" = 1;
            "on-click" = "pavucontrol";
          };
          mpris = {
            format = "{player_icon} {dynamic}";
            format-paused = "{status_icon} <i>{dynamic}</i>";
            dynamic-order = [
              "title"
              "artist"
            ];
            player-icons = {
              default = "▶";
              mpv = "🎵";
            };
            status-icons = {
              paused = "⏸";
            };
            ignored-players = [
              "firefox"
              "brave"
            ];
          };
          "sway/workspaces" = {
            disable-scroll = true;
            on-click = "activate";
            format = " {index} /";
            sort-by-number = true;
          };
          "wlr/taskbar" = {
            format = " {icon} |";
            on-click = "activate";
          };
          memory = {
            interval = 10;
            format = "{used}G/{total}G";
          };
          clock = {
            format = "{:%H:%M} ";
            format-alt = "{:%A, %B %d, %Y (%R)}  ";
            tooltip-format = "{calendar}";
            calendar = {
              mode = "year";
              mode-mon-col = 3;
              weeks-pos = "right";
              on-scroll = 1;
              format = {
                months = "<span color='${rgbTheme.normal.blue}'><b>{}</b></span>";
                days = "<span color='${rgbTheme.foreground}'><b>{}</b></span>";
                weeks = "<span color='${rgbTheme.normal.cyan}'><b>W{}</b></span>";
                weekdays = "<span color='${rgbTheme.normal.cyan}'><b>{}</b></span>";
                today = "<span color='${rgbTheme.normal.green}'><b><u>{}</u></b></span>";
              };
            };
            actions = {
              on-click-right = "mode";
              on-scroll-up = "shift_up";
              on-scroll-down = "shift_down";
            };
          };
          cpu = {
            interval = 1;
            format = "{load}% ";
          };
          upower = {
            format = " {percentage} ";
            format-alt = " {percentage} - {time} ";
            tooltip = false;
          };
          "custom/separator" = {
            format = " | ";
            tooltip = false;
          };
        };
      };
      style = ''
        /* Modified from
          https://github.com/Pipshag/dotfiles_gruvbox/blob/master/.config/waybar/style.css
        */
        @define-color bg ${rgbTheme.background};
        @define-color fg ${rgbTheme.foreground};
        @define-color critical ${rgbTheme.normal.red};
        @define-color warning ${rgbTheme.normal.yellow};
        @define-color focus ${rgbTheme.normal.green};
        @define-color subtle ${rgbTheme.normal.blue};

        * {
            border: none;
            border-radius: 0px;
            min-height: 0;
        }

        #waybar {
            background: @bg;
            color: @fg;
            font-family: "${pkgs.rice.font.monospace.name}",
              "Font Awesome 6 Brands Regular",
              "Font Awesome 6 Free Solid",
              "Font Awesome 6 Free Regular";
            font-size: 11pt;
            font-weight: bold;
        }

        /* Each module that should blink */
        #mode,
        #memory,
        #temperature,
        #battery {
            animation-timing-function: linear;
            animation-iteration-count: infinite;
            animation-direction: alternate;
        }

        /* Each critical module */
        #memory.critical,
        #cpu.critical,
        #temperature.critical,
        #battery.critical {
            color: @critical;
        }

        /* Each critical that should blink */
        #mode,
        #memory.critical,
        #temperature.critical,
        #battery.critical.discharging {
            animation-name: blink-critical;
            animation-duration: 2s;
        }

        /* Each warning */
        #network.disconnected,
        #memory.warning,
        #cpu.warning,
        #temperature.warning,
        #battery.warning {
            background: @warning;
        }

        /* Each warning that should blink */
        #battery.warning.discharging {
            animation-name: blink-warning;
            animation-duration: 3s;
        }

        #workspaces button, #cpu, #memory, #pulseaudio, #upower {
          background: @bg;
          color: @fg;
          padding: 0;
        }

        #workspaces button.focused {
          background: @bg;
          color: @focus;
        }
      '';

      systemd = {
        enable = true;
      };
    };
  };
}
