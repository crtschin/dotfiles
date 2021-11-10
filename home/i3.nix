{ config, lib, pkgs, ... }:

let
  mod = "Mod4";
  polybarStart =
    ''
for m in $(polybar --list-monitors | ${pkgs.coreutils}/bin/cut -d":" -f1); do
  MONITOR=$m polybar --reload main &
done
    ''
  ;
in {
  imports = [
    ./polybar.nix
  ];

  programs = {
    rofi = {
      enable = true;
      font = "FontAwesome, Fira Code 12, DejaVu Sans Mono 12";
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
    polybar.script = polybarStart;
    picom = {
      package = pkgs.picom;
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
no-fading-openclose = true;
mark-wmwin-focused = true;
mark-ovredir-focused = true;
use-ewmh-active-win = true;
detect-client-opacity = true;

focus-exclude = [
	"class_g ?= 'rofi'"
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
  };
  xdg.enable = true;
  xdg.mime.enable = true;

  xresources.properties = {
    "*background"= "#282828";
    "*foreground"= "#ebdbb2";
    "*color0"=  "#282828";
    "*color8"=  "#928374";
    "*color1"=  "#cc241d";
    "*color9"=  "#fb4934";
    "*color2"=  "#98971a";
    "*color10"= "#b8bb26";
    "*color3"=  "#d79921";
    "*color11"= "#fabd2f";
    "*color4"=  "#458588";
    "*color12"= "#83a598";
    "*color5"=  "#b16286";
    "*color13"= "#d3869b";
    "*color6"=  "#689d6a";
    "*color14"= "#8ec07c";
    "*color7"=  "#a89984";
    "*color15"= "#ebdbb2";
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
          names = ["Font Awesome 5 Free, Fira Code, DejaVu Sans Mono, Monospace"];
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
      extraConfig =
        ''
#######
#THEME#
#######

# set primary gruvbox colorscheme colors
set $bg #282828
set $red #cc241d
set $green #98971a
set $yellow #d79921
set $blue #458588
set $purple #b16286
set $aqua #689d68
set $gray #a89984
set $darkgray #1d2021
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
# for_window [class=".*"] title_format "<span font='Fira Code 12'>%title</span>"
exec_always --no-startup-id polybar-msg cmd restart
exec --no-startup-id ${pkgs.nitrogen}/bin/nitrogen --restore
exec --no-startup-id systemctl --user start playerctld polybar picom

assign [class="Code"] 1
assign [class="kitty"] 10
assign [class="alacritty"] 10
assign [class="Firefox"] 2
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
        ''
      ;
    };
  };
}
