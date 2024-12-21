{
  config,
  lib,
  pkgs,
  ...
}:
let
  polybarStart = ''
    for m in $(polybar --list-monitors | ${pkgs.coreutils}/bin/cut -d":" -f1); do
      MONITOR=$m polybar --reload main &
    done
  '';
  rgbTheme = pkgs.riceRgbColorPalette;
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
  services = {
    polybar = {
      package = pkgs.polybar.override {
        i3Support = true;
        alsaSupport = true;
        githubSupport = true;
        mpdSupport = true;
        pulseSupport = true;
        nlSupport = true;
      };
      script = polybarStart;
      extraConfig = ''
        [colors]
        background = ${rgbTheme.background}
        foreground = ${rgbTheme.foreground}
        red        = ${rgbTheme.normal.red}
        green      = ${rgbTheme.normal.green}
        yellow     = ${rgbTheme.normal.yellow}
        blue       = ${rgbTheme.normal.blue}
        purple     = ${rgbTheme.normal.magenta}
        teal       = ${rgbTheme.normal.cyan}
        lightgray  = ${rgbTheme.bright.black}
        gray       = ${rgbTheme.normal.black}
        darkgray   = ${rgbTheme.dark.black}

        background-alt = ''${colors.darkgray}
        foreground-alt = ''${colors.gray}
        primary = ''${colors.green}
        secondary = ''${colors.teal}
        alert = ''${colors.purple}

        good = ''${colors.green}
        degraded = ''${colors.yellow}
        bad = ''${colors.red}

        [bar/common]
        width = 100%
        height = 27
        fixed-center = false

        enable-ipc = true

        background = ''${colors.background}
        foreground = ''${colors.foreground}

        bottom = false

        line-size = 3
        line-color = #f00

        border-top-size = 1
        border-color = #00000000

        padding-left = 0
        padding-right = 1

        module-margin-left = 1
        module-margin-right = 1

        font-0 = ${pkgs.rice.font.monospace.name}:pixelsize=13;1
        font-1 = Font Awesome 6 Brands Regular:pixelsize=13;1
        font-2 = Font Awesome 6 Free Solid:pixelsize=13;1
        font-3 = Font Awesome 6 Free Regular:pixelsize=13;1

        tray-position = right
        tray-padding = 1

        cursor-click = pointer

        scroll-up = "#i3.prev"
        scroll-down = "#i3.next"

        [bar/main]
        inherit=bar/common
        monitor = ''${env:MONITOR:}

        modules-left = i3
        modules-center = media
        modules-right = pulseaudio battery memory cpu wlan date powermenu

        [module/wlan]
        inherit=module/wlan_common
        interface = wlp59s0

        [module/xwindow]
        type = internal/xwindow
        label = %title:0:30:...%

        [module/filesystem]
        type = internal/fs
        interval = 25

        mount-0 = /

        label-mounted = %mountpoint%: %free%
        label-unmounted = %mountpoint%: 
        label-unmounted-foreground = ''${colors.foreground-alt}

        [module/i3]
        type = internal/i3
        format = <label-state> <label-mode>
        index-sort = true
        pin-workspaces = true
        wrapping-scroll = false

        ; Only show workspaces on the same output as the bar
        ;pin-workspaces = true

        label-mode-padding = 1
        label-mode-foreground = #000
        label-mode-background = ''${colors.primary}

        ; focused = Active workspace on focused monitor
        label-focused = %index%
        label-focused-background = ''${colors.background-alt}
        label-focused-underline= ''${colors.primary}
        label-focused-padding = 1

        ; unfocused = Inactive workspace on any monitor
        label-unfocused = %index%
        label-unfocused-padding = 1

        ; visible = Active workspace on unfocused monitor
        label-visible = %index%
        label-visible-background = ''${self.label-focused-background}
        label-visible-underline = ''${self.label-focused-underline}
        label-visible-padding = ''${self.label-focused-padding}

        ; urgent = Workspace with urgency hint set
        label-urgent = %index%
        label-urgent-background = ''${colors.alert}
        label-urgent-padding = 1

        [module/cpu]
        type = internal/cpu
        interval = 2
        format-prefix =
        label =  %percentage:2%%

        [module/battery]
        type = internal/battery
        full-at = 99
        low-at = 10
        battery = BAT0
        adapter = ADP1
        format-prefix =
        format-charging = <label-charging>
        format-discharging = <label-discharging>
        label-charging = 🔌 %percentage%%
        label-discharging = 🔋 %percentage%% (%time%)
        poll-interval = 5

        [module/memory]
        type = internal/memory
        interval = 2
        format-prefix =
        label =  %gb_free%

        [module/wlan_common]
        type = internal/network
        interface = wlp59s0
        interval = 3.0

        format-prefix =
        format-connected = <label-connected>
        label-connected =  %essid% (%local_ip%)

        format-disconnected =

        [module/eth_common]
        type = internal/network
        interface = enp5s0
        interval = 3.0
        label-connected =  %local_ip%
        format-disconnected =

        [module/date]
        type = internal/date
        interval = 1

        date = " %d %b"
        date-alt = " %Y-%m-%d"

        time = %H:%M
        time-alt = %H:%M:%S

        format-prefix =
        format-prefix-foreground = ''${colors.foreground-alt}

        label =  %date% %time%

        [module/pulseaudio]
        type = internal/pulseaudio

        format-volume = <ramp-volume> <label-volume> <bar-volume>
        label-volume = %percentage%%
        ; label-volume-foreground = ''${root.foreground}

        label-muted = " muted"
        label-muted-minlen = 17
        label-muted-alignment = center
        label-muted-foreground = ''${colors.lightgray}

        ramp-volume-0 = 
        ramp-volume-1 = 
        ramp-volume-2 = 

        bar-volume-width = 10
        bar-volume-foreground-0 = ''${colors.green}
        bar-volume-foreground-1 = ''${colors.green}
        bar-volume-foreground-2 = ''${colors.green}
        bar-volume-foreground-3 = ''${colors.green}
        bar-volume-foreground-4 = ''${colors.green}
        bar-volume-foreground-5 = ''${colors.yellow}
        bar-volume-foreground-6 = ''${colors.red}
        bar-volume-gradient = false
        bar-volume-indicator = |
        ; bar-volume-indicator-font = 2
        bar-volume-fill = |
        ; bar-volume-fill-font = 2
        bar-volume-empty = |
        ; bar-volume-empty-font = 2
        bar-volume-empty-foreground = ''${colors.foreground-alt}

        [module/cpu_temperature]
        type = internal/temperature

        hwmon-path = /sys/devices/virtual/thermal/thermal_zone9/hwmon4/temp1_input

        base-temperature = 40
        warn-temperature = 70

        format = <ramp> <label>
        format-warn = <ramp> <label-warn>

        label = %temperature-c%
        label-warn = %temperature-c%
        label-warn-foreground = ''${colors.alert}

        ramp-0 = 
        ramp-1 = 
        ramp-2 = 
        ramp-3 = 
        ramp-4 = 
        ramp-foreground = ''${colors.foreground-alt}

        [module/gpu_temperature]
        inherit = module/cpu_temperature

        hwmon-path = /sys/devices/pci0000:00/0000:00:1d.0/0000:3d:00.0/hwmon/hwmon3/temp1_input

        [module/powermenu]
        type = custom/menu

        expand-right = true

        format-spacing = 1

        label-open = 
        label-open-foreground = ''${colors.secondary}
        label-close = 
        label-close-foreground = ''${colors.secondary}
        label-separator = |
        label-separator-foreground = ''${colors.foreground-alt}

        menu-0-0 =  reboot
        menu-0-0-exec = reboot
        menu-0-1 =  power off
        menu-0-1-exec = poweroff
        menu-0-2 =  logout
        menu-0-2-exec = gnome-session-quit --logout --no-prompt

        [module/media]
        type = custom/script
        exec = ${pkgs.playerctl}/bin/playerctl metadata --player playerctld --format "{{ title }} - {{ artist }}" || true
        interval = 1
        format = <label>
        format-prefix = " "
        format-prefix-foreground = ''${colors.foreground-alt}
        format-suffix = " "
        format-suffix-foreground = ''${colors.foreground-alt}
        click-left = ${pkgs.playerctl}/bin/playerctl play-pause --player playerctld
        double-click-left = ${pkgs.playerctl}/bin/playerctl next --player playerctld
        click-right = ${pkgs.playerctl}/bin/playerctl previous --player playerctld

        [settings]
        screenchange-reload = true

        [global/wm]
        margin-top = 0
        margin-bottom = 0

        ; vim:ft=dosini
      '';
    };
  };
}
