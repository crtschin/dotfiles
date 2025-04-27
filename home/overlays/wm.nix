self: super:
let
  modifier = super.configuration.variables.modifier;
  terminal = super.configuration.terminal;
  rgbTheme = super.riceExtendedColorPalette;
  toLockColor = color: super.lib.strings.removePrefix "#" color;
  generic = programLauncher: lockscreenCmd: {
    assign = ''
      assign [class="Code"] 1
      assign [class="kitty"] 10
      assign [class="alacritty"] 10
      assign [class="Firefox"] 2
      assign [class="Brave"] 2
      assign [class="Spotify"] 9
    '';
    colorTheme = ''
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
      # for_window [class=".*"] title_format "<span font='${super.rice.font.monospace.name}'>%title</span>"
    '';
    fonts = {
      names = [
        "Font Awesome 5 Free, ${super.rice.font.monospace.name}, DejaVu Sans Mono, Monospace"
      ];
      style = "Bold Semi-Condensed";
      size = 11.0;
    };

    keybindings = super.lib.mkOptionDefault {
      "${modifier}+p" = "exec PATH=~/.nix-profile/bin:$PATH ${programLauncher}";
      "${modifier}+q" = "kill";
      "${modifier}+Return" = "exec PATH=~/.nix-profile/bin:$PATH ${terminal}/bin/${terminal.name}";
      "${modifier}+Tab" = "workspace back_and_forth";
      "${modifier}+Shift+r" = "restart";
      "${modifier}+l" = lockscreenCmd;
      "${modifier}+m" = "move workspace to output left";
      "${modifier}+Shift+p" = "exec flameshot gui";
    };
    workspaces = ''
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
  };
  i3Config = generic "${super.rofi}/bin/rofi -show" "exec betterlockscreen -l dim";
  swayConfig = generic "${super.wofi}/bin/wofi --show run,drun" swaylockCommand;
  swaylockCommand = (
    super.lib.concatStrings [
      "exec swaylock"
      " -n"
      " -c ${toLockColor rgbTheme.background}"
      " --font ${super.rice.font.monospace.name}"
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
      " --image ~/Pictures/Wallpapers/background.png"
    ]
  );
in
{
  configuration = super.configuration // {
    i3 = i3Config;
    sway = swayConfig;
  };
}
