{ config, lib, pkgs, ... }:

let
  mod = "Mod4";
in {
  programs = {
    rofi = {
      enable = true;
      font = "FontAwesome, Fira Code 12, DejaVu Sans Mono 12";
      terminal = "${pkgs.kitty}/bin/kitty";
      theme = "gruvbox-dark-hard";
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

  services.picom = {
    enable = true;
    blur = true;
    fade = true;
    fadeDelta = 2;
    inactiveOpacity = "0.8";
    inactiveDim = "0.3";
    vSync = true;
    experimentalBackends = true;
    extraOptions =
      ''
mark-overdir-focused = true;
mark-wmwin-focused = true;
focus-exclude = [
	# "class_g ?= 'rofi'"
];
blur:
{
  method = "gaussian";
  size = 10;
  deviation = 5.0;
};
      ''
    ;
  };

  xsession.windowManager.i3 = {
    package = pkgs.i3-gaps;
    enable = true;
    config = {
      modifier = mod;
      gaps = {
        inner = 15;
        outer = 0;
      };

      fonts = {
        names = ["FontAwesome5Free, Fira Code, DejaVu Sans Mono, Monospace"];
        style = "Bold Semi-Condensed";
        size = 11.0;
      };

      keybindings = lib.mkOptionDefault {
        "${mod}+p" = "exec ${pkgs.rofi}/bin/rofi -show";
        "${mod}+w" = "kill";
        "${mod}+Return" = "exec $TERMINAL";
        "${mod}+Tab" = "workspace back_and_forth";
        "${mod}+Shift+r" = "restart";
        "${mod}+l" = "exec ${pkgs.i3lock-fancy}/bin/i3lock-fancy -p -t ''";
        "${mod}+m" = "move workspace to output left";
      };
      bars = [];
    };
    extraConfig =
      ''
# Theme
client.focused #000000 #000000 #FFFFFF #000000
client.focused_inactive #333333 #333333 #FFFFFF #000000
client.unfocused #333333 #333333 #FFFFFF #333333
client.urgent #cc241d #cc241d #ebdbb2 #282828

for_window [class=".*"] border pixel 0
# for_window [class=".*"] title_format "<span font='Fira Code 12'>%title</span>"
exec_always --no-startup-id polybar-msg cmd restart
exec --no-startup-id polybar --reload main
exec --no-startup-id polybar --reload secondary
exec_always --no-startup-id picom
      ''
    ;
  };
}
