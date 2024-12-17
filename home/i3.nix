{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  enableWayland = true;
  mod = "Mod4";
  rgbTheme = pkgs.riceRgbColorPalette;
  toLockColor = color: lib.strings.removePrefix "#" color;
  i3ColorTheme = ''
    # set primary gruvbox colorscheme colors
    set $bg ${rgbTheme.background}
    set $red ${rgbTheme.normal.red}
    set $green ${rgbTheme.normal.green}
    set $yellow ${rgbTheme.normal.yellow}
    set $blue ${rgbTheme.normal.blue}
    set $purple ${rgbTheme.normal.magenta}
    set $aqua ${rgbTheme.normal.cyan}
    set $gray ${rgbTheme.normal.white}
    set $darkgray ${rgbTheme.normal.black}
    set $white ${rgbTheme.normal.white}

    # green gruvbox
    client.focused          $green $green $darkgray $purple $green
    client.focused_inactive $darkgray $darkgray $yellow $purple $darkgray
    client.unfocused        $darkgray $darkgray $yellow $purple $darkgray
    client.urgent           $red $red $white $red $red

    # blue gruvbox
    # client.focused          $blue $blue $darkgray $purple $darkgray
    # client.focused_inactive $darkgray $darkgray $yellow $purple $darkgray
    # client.unfocused        $darkgray $darkgray $yellow $purple $darkgray
    # client.urgent           $red $red $white $red $red

    for_window [class=".*"] border pixel 2
    # for_window [class=".*"] title_format "<span font='${pkgs.rice.font.monospace.name}'>%title</span>"
  '';
  i3Font = {
    names = [
      "Font Awesome 5 Free, ${pkgs.rice.font.monospace.name}, DejaVu Sans Mono, Monospace"
    ];
    style = "Bold Semi-Condensed";
    size = 11.0;
  };
  i3Keybindings =
    launchApp: lockWindow:
    lib.mkOptionDefault {
      "${mod}+p" = "exec PATH=~/.nix-profile/bin:$PATH ${launchApp}";
      "${mod}+q" = "kill";
      "${mod}+Return" = "exec PATH=~/.nix-profile/bin:$PATH ${pkgs.kitty}/bin/kitty";
      "${mod}+Tab" = "workspace back_and_forth";
      "${mod}+Shift+r" = "restart";
      "${mod}+l" = lockWindow;
      "${mod}+m" = "move workspace to output left";
      "${mod}+Shift+p" = "exec flameshot gui";
    };
  i3Workspaces = ''
    workspace 10 output primary
    workspace 1 output secondary
    workspace 2 output secondary
    workspace 3 output secondary
    workspace 4 output secondary
    workspace 5 output secondary
    workspace 6 output secondary
    workspace 7 output secondary
    workspace 8 output secondary
    workspace 9 output secondary
  '';
in
{
  home.packages =
    with pkgs;
    if enableWayland then
      [
        swaybg
        waybar
        wl-clipboard
        grim
      ]
    else
      [ ];
  programs = {
    rofi = {
      enable = !enableWayland;
      font = "FontAwesome, ${pkgs.rice.font.monospace.name}, DejaVu Sans Mono 12";
      terminal = "${pkgs.kitty}/bin/kitty";
      theme = "gruvbox-dark-soft";
      extraConfig = {
        modi = "run,combi";
        combi-modi = "run";
        icon-theme = "Papirus";
        show-icons = true;
        fuzzy = true;
        normal-window = true;
      };
    };
    waybar = {
      enable = enableWayland;
    };
    wofi = {
      enable = enableWayland;
      style = ''
        ${builtins.readFile (inputs.wofi-themes + "/themes/gruvbox.css")}
      '';
      settings = {
        layer = "overlay";
        allow_markup = true;
      };
    };
  };

  services = {
    flameshot = {
      enable = true;
      package = pkgs.flameshotGrim;
    };
    kanshi = {
      enable = enableWayland;
      settings = [
        {
          profile.name = "undocked";
          profile.outputs = [
            {
              criteria = "eDP-1";
              status = "enable";
              mode = "1920x1200";
            }
          ];
        }
        {
          profile.name = "home";
          profile.outputs = [
            {
              criteria = "eDP-1";
              status = "enable";
              mode = "1920x1200";
              position = "1920,520";
            }
            {
              criteria = "AOC 2460G5 F54GABA004914";
              status = "enable";
              mode = "1920x1080";
              position = "0,0";
            }
          ];
        }
        {
          profile.name = "docked_dual";
          profile.outputs = [
            {
              criteria = "eDP-1";
              status = "disable";
            }
            {
              criteria = "Dell Inc. DELL U2719D 74RRT13";
              position = "0,0";
              mode = "2560x1440";
            }
            {
              criteria = "Dell Inc. DELL U2717D J0XYN99BA3TS";
              position = "2560,0";
              mode = "2560x1440";
            }
          ];
        }
      ];
    };
    screen-locker = {
      enable = false;
      # lockCmd = "${pkgs.betterlockscreen}/bin/betterlockscreen -l dim";
    };
    polybar = {
      enable = !enableWayland;
    };
    picom = {
      package = pkgs.picom;
      enable = false;
      fade = true;
      fadeDelta = 2;
      inactiveOpacity = 0.8;
      settings = {
        experimental-backends = true;
        no-fading-openclose = true;
        mark-wmwin-focused = true;
        mark-ovredir-focused = true;
        use-ewmh-active-win = true;
        detect-client-opacity = true;
        focus-exclude = [ "class_g ?= 'rofi'" ];
        blur = {
          method = "gaussian";
          size = 10;
          deviation = 5.0;
        };
        inactive-dim = "0.3";
        vsync = true;
      };
    };
  };

  wayland = {
    windowManager = {
      hyprland = {
        enable = false;
        xwayland.enable = true;
      };
      sway = {
        enable = enableWayland;
        package = pkgs.sway;
        checkConfig = true;
        systemd.enable = true;
        wrapperFeatures = {
          gtk = true;
        };
        extraConfig = ''
          exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway

          ${i3ColorTheme}
          smart_gaps on
          gaps inner 10

          ${i3Workspaces}
          bar {
            swaybar_command waybar
          }
        '';
        config = {
          assigns = {
            "10: terminal" = [
              { class = "kitty"; }
            ];
            "9: music" = [
              { class = "Spotify"; }
            ];
            "2: web" = [
              { class = "Firefox"; }
              { class = "Brave"; }
            ];
            "1: code" = [
              {
                class = "Code";
                window_role = "About";
              }
            ];
          };
          fonts = i3Font;
          keybindings = i3Keybindings "${pkgs.wofi}/bin/wofi --show run,drun" (
            lib.concatStrings [
              "exec swaylock"
              " -n"
              " -c ${toLockColor rgbTheme.background}"
              " --font ${pkgs.rice.font.monospace.name}"
              " --text-color ${toLockColor rgbTheme.foreground}"
              " --text-clear-color ${toLockColor rgbTheme.foreground}"
              " --text-ver-color ${toLockColor rgbTheme.foreground}"
              " --text-wrong-color ${toLockColor rgbTheme.foreground}"
              " --key-hl-color ${toLockColor rgbTheme.normal.green}"
              " --bs-hl-color ${toLockColor rgbTheme.normal.yellow}"
              " --ring-clear-color ${toLockColor rgbTheme.normal.yellow}"
              " --ring-color ${toLockColor rgbTheme.normal.cyan}"
              " --ring-ver-color ${toLockColor rgbTheme.normal.white}"
              " --ring-wrong-color ${toLockColor rgbTheme.normal.red}"
              " --inside-clear-color ${toLockColor rgbTheme.background}"
              " --inside-color ${toLockColor rgbTheme.background}"
              " --inside-ver-color ${toLockColor rgbTheme.background}"
              " --inside-wrong-color ${toLockColor rgbTheme.background}"
              " --line-clear-color ${toLockColor rgbTheme.normal.black}"
              " --line-color ${toLockColor rgbTheme.normal.black}"
              " --line-ver-color ${toLockColor rgbTheme.normal.black}"
              " --line-wrong-color ${toLockColor rgbTheme.normal.black}"
            ]
          );
          bars = [ ];
          modifier = mod;
          terminal = "kitty";
        };
      };
    };
  };

  xdg = {
    portal = {
      enable = enableWayland;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
      ];
      config = {
        common = {
          default = [
            "wlr"
          ];
        };
      };
    };
  };

  xresources.properties = {
    "Xft.antialias" = "1";
    "Xft.autohint" = "0";
    "Xft.hinting" = "1";
    "Xft.hintstyle" = "hintnone";
    "Xft.lcdfilter" = "lcddefault";
    "Xft.rgba" = "rgb";

    "*background" = rgbTheme.background;
    "*foreground" = rgbTheme.foreground;
    "*color0" = rgbTheme.color0;
    "*color1" = rgbTheme.color1;
    "*color2" = rgbTheme.color2;
    "*color3" = rgbTheme.color3;
    "*color4" = rgbTheme.color4;
    "*color5" = rgbTheme.color5;
    "*color6" = rgbTheme.color6;
    "*color7" = rgbTheme.color7;
    "*color8" = rgbTheme.color8;
    "*color9" = rgbTheme.color9;
    "*color10" = rgbTheme.color10;
    "*color11" = rgbTheme.color11;
    "*color12" = rgbTheme.color12;
    "*color13" = rgbTheme.color13;
    "*color14" = rgbTheme.color14;
    "*color15" = rgbTheme.color15;
  };

  xsession = {
    enable = !enableWayland;
    windowManager.i3 = {
      package = pkgs.i3-gaps;
      enable = !enableWayland;
      config = {
        modifier = mod;
        gaps = {
          inner = 10;
        };
        fonts = i3Font;
        keybindings = i3Keybindings "${pkgs.rofi}/bin/rofi -show" "exec betterlockscreen -l dim";
        bars = [ ];
      };
      extraConfig = ''
        ${i3ColorTheme}

        exec_always --no-startup-id polybar-msg cmd restart
        exec --no-startup-id ${pkgs.nitrogen}/bin/nitrogen --restore
        exec --no-startup-id systemctl --user start playerctld polybar picom

        assign [class="Code"] 1
        assign [class="kitty"] 10
        assign [class="alacritty"] 10
        assign [class="Firefox"] 2
        assign [class="Brave"] 2
        assign [class="Spotify"] 9

        ${i3Workspaces}
      '';
    };
  };
}
