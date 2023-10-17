{
  config,
  lib,
  pkgs,
  ...
}: let
  mod = "Mod4";
  rgbTheme = pkgs.riceRgbColorPalette;
in {
  programs = {
    rofi = {
      enable = true;
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
  };

  services = {
    screen-locker = {
      enable = false;
      lockCmd = "${pkgs.betterlockscreen}/bin/betterlockscreen -l dim";
    };
    picom = {
      package = pkgs.picom;
      enable = true;
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
        focus-exclude = [
          "class_g ?= 'rofi'"
        ];
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
    enable = true;
    windowManager.i3 = {
      package = pkgs.i3-gaps;
      enable = true;
      config = {
        modifier = mod;
        gaps = {
          inner = 10;
        };
        fonts = {
          names = ["Font Awesome 5 Free, ${pkgs.rice.font.monospace.name}, DejaVu Sans Mono, Monospace"];
          style = "Bold Semi-Condensed";
          size = 11.0;
        };

        keybindings = lib.mkOptionDefault {
          "${mod}+p" = "exec ${pkgs.rofi}/bin/rofi -show";
          "${mod}+q" = "kill";
          "${mod}+Return" = "exec $TERMINAL";
          "${mod}+Tab" = "workspace back_and_forth";
          "${mod}+Shift+r" = "restart";
          "${mod}+l" = "exec ${pkgs.betterlockscreen}/bin/betterlockscreen -l dim";
          "${mod}+m" = "move workspace to output left";
          "${mod}+Shift+p" = "exec flameshot gui";
        };
        bars = [];
      };
      extraConfig = ''
        #######
        #THEME#
        #######

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
        exec_always --no-startup-id polybar-msg cmd restart
        exec --no-startup-id ${pkgs.nitrogen}/bin/nitrogen --restore
        exec --no-startup-id systemctl --user start playerctld polybar picom

        assign [class="Code"] 1
        assign [class="kitty"] 10
        assign [class="alacritty"] 10
        assign [class="Firefox"] 2
        assign [class="Brave"] 2
        assign [class="pgadmin4"] 3
        assign [class="Spotify"] 9

        workspace 1 output primary
        workspace 2 output secondary
        workspace 3 output secondary
        workspace 4 output secondary
        workspace 5 output secondary
        workspace 6 output secondary
        workspace 7 output secondary
        workspace 8 output secondary
        workspace 9 output secondary
        workspace 10 output secondary
      '';
    };
  };
}
