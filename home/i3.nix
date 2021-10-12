{ config, lib, pkgs, ... }:

let
  mod = "Mod4";
in {
  programs = {
    rofi = {
      enable = true;
      font = "Fira Code 12, DejaVu Sans Mono 12";
      terminal = "${pkgs.alacritty}/bin/alacritty";
      theme = "gruvbox-dark-hard";
      extraConfig = {
        modi = "run,combi";
        combi-modi = "run";
        icon-theme = "Papirus";
        show-icons = true;
      };
    };
  };
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = mod;

      fonts = ["Fira Code 12, DejaVu Sans Mono 12, Monospace 12"];

      keybindings = lib.mkOptionDefault {
        "${mod}+p" = "exec ${pkgs.rofi}/bin/rofi -show";
        "${mod}+w" = "kill";
        "${mod}+Return" = "exec $TERMINAL";
        "${mod}+Tab" = "workspace back_and_forth";
        "${mod}+Shift+r" = "restart";
        "${mod}+l" = "${pkgs.i3lock-fancy}/bin/i3lock-fancy -p -t ''";
        "${mod}+m" = "move workspace to output left";
      };
      bars = [];
    };
    extraConfig =
      ''
for_window [class=".*"] title_format "<span font='Fira Code 12'>%title</span>"
exec_always --no-startup-id polybar-msg cmd restart
exec --no-startup-id polybar --reload main
exec --no-startup-id polybar --reload secondary
      ''
    ;
  };
}
