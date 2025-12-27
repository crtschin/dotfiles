{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  configuration = pkgs.configuration;
  rgbTheme = pkgs.riceExtendedColorPalette;
  enable = configuration.flags.sway;
  wayland = configuration.flags.protocol.wayland;
in
{
  home.packages =
    with pkgs;
    pkgs.onlyIfList enable [
      swaybg
      waybar
      wl-clipboard
      grim
    ];

  programs = {
    waybar = {
      enable = wayland;
    };
    wofi = {
      enable = wayland;
      style = ''
        ${builtins.readFile (inputs.wofi-themes + "/themes/gruvbox.css")}
      '';
      settings = {
        layer = "overlay";
        allow_markup = true;
      };
    };
  };
  wayland = {
    windowManager = {
      sway = {
        inherit enable;
        package = pkgs.sway;
        checkConfig = false;
        systemd.enable = true;
        wrapperFeatures = {
          gtk = false;
          base = true;
        };
        extraConfig = ''
          include /etc/sway/config.d/*
          exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway

          ${configuration.sway.colorTheme}
          smart_gaps on
          gaps inner 10

          ${configuration.sway.assign}
          ${configuration.sway.workspaces}
          # bar {
          #   swaybar_command waybar
          # }

          output * bg ${rgbTheme.primary.dim_background} solid_color
        '';
        config = {
          assigns = {
            # "10: terminal" = [
            #   { app_id = configuration.terminal.name; }
            # ];
            "9: music" = [
              { class = "Spotify"; }
            ];
            "2: web" = [
              { class = "Firefox"; }
              { instance = "brave-browser"; }
            ];
            "1: code" = [
              {
                app_id = "code";
              }
            ];
          };
          fonts = configuration.sway.fonts;
          keybindings = configuration.sway.keybindings;
          startup = [
            { command = configuration.variables.terminal; }
          ];
          bars = [ ];
          modifier = configuration.variables.modifier;
          terminal = configuration.terminal.name;
        };
      };
    };
  };
}
