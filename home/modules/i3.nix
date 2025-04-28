{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  configuration = pkgs.configuration;
  enabled = pkgs.configuration.flags.i3;
  rgbTheme = pkgs.riceExtendedColorPalette;
in
{
  programs = {
    rofi = {
      enable = enabled;
      font = "FontAwesome, ${pkgs.rice.font.monospace.name}, DejaVu Sans Mono 12";
      terminal = configuration.variables.terminal;
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
    };
    polybar = {
      enable = enabled;
    };
    picom = {
      enable = false;
      package = pkgs.picom;
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
    enable = enabled;
    windowManager.i3 = {
      package = pkgs.i3-gaps;
      enable = enabled;
      config = {
        modifier = configuration.variables.modifier;
        gaps = {
          inner = 10;
        };
        fonts = configuration.i3.fonts;
        keybindings = configuration.i3.keybindings;
        bars = [ ];
      };
      extraConfig = ''
        ${configuration.i3.colorTheme}

        exec_always --no-startup-id polybar-msg cmd restart
        exec --no-startup-id ${pkgs.nitrogen}/bin/nitrogen --restore
        exec --no-startup-id systemctl --user start playerctld polybar picom

        ${configuration.i3.workspaces}
      '';
    };
  };
}
