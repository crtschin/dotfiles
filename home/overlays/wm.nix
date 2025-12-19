self: super:
let
  configuration = super.configuration;
  modifier = configuration.variables.modifier;
  rgbTheme = super.riceExtendedColorPalette;
  toLockColor = color: super.lib.strings.removePrefix "#" color;
  generic = programLauncher: lockscreenCmd: {
    assign = ''
      assign [class="Code"] 1
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

      # Unbind unused layouts
      unbindsym ${modifier}+b
      unbindsym ${modifier}+e
      unbindsym ${modifier}+s
      unbindsym ${modifier}+v
      unbindsym ${modifier}+w
    '';
    fonts = {
      names = [
        "Font Awesome 5 Free, ${super.rice.font.monospace.name}, DejaVu Sans Mono, Monospace"
      ];
      # style = "Bold Semi-Condensed";
      size = "${toString super.rice.font.monospace.size}";
    };

    keybindings = super.lib.mkOptionDefault {
      "${modifier}+p" = "exec PATH=~/.nix-profile/bin:$PATH ${programLauncher}";
      "${modifier}+q" = "kill";
      "${modifier}+Return" = "exec PATH=~/.nix-profile/bin:$PATH ${configuration.variables.terminal}";
      "${modifier}+Shift+Return" = "exec PATH=~/.nix-profile/bin:$PATH ${configuration.variables.terminal} quick-access-terminal";
      "${modifier}+Tab" = "workspace back_and_forth";
      "${modifier}+Shift+r" = "restart";
      "${modifier}+Shift+l" = lockscreenCmd;
      "${modifier}+m" = "move workspace to output left";
      "${modifier}+Shift+p" = "exec flameshot gui";
      "XF86AudioRaiseVolume" = "exec playerctl volume 0.05+";
      "XF86AudioLowerVolume" = "exec playerctl volume 0.05-";
      "XF86AudioStop" = "exec playerctl play-pause";
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
  hyprlandConfig = {
    workspaceAssignments = [
      "10, monitor:primary"
      "1, monitor:secondary"
      "2, monitor:secondary"
      "3, monitor:secondary"
      "4, monitor:secondary"
      "5, monitor:secondary"
      "6, monitor:secondary"
      "7, monitor:secondary"
      "8, monitor:secondary"
      "9, monitor:secondary"
    ];
    windowRules = [
      "workspace 1 silent, class:^(code)$"
      "workspace 1 silent, class:^(Code)$"
      "workspace 2 silent, class:^(firefox)$"
      "workspace 2 silent, class:^(Firefox)$"
      "workspace 2 silent, class:^(brave-browser)$"
      "workspace 2 silent, class:^(Brave)$"
      "workspace 9 silent, class:^(Spotify)$"
    ];
    keybindings = hyprModifier: [
      "${hyprModifier}, p, exec, PATH=~/.nix-profile/bin:$PATH ${super.hyprlauncher}/bin/hyprlauncher"
      "${hyprModifier}, q, killactive,"
      "${hyprModifier}, Return, exec, PATH=~/.nix-profile/bin:$PATH ${configuration.variables.terminal}"
      "${hyprModifier} SHIFT, Return, exec, PATH=~/.nix-profile/bin:$PATH ${configuration.variables.terminal} quick-access-terminal"
      "${hyprModifier}, Tab, workspace, previous"
      "${hyprModifier} SHIFT, r, exec, hyprctl reload"
      "${hyprModifier} SHIFT, l, exec, ${super.swaylock}/bin/swaylock -n -c ${toLockColor rgbTheme.background} --font ${super.rice.font.monospace.name}"
      "${hyprModifier}, m, movecurrentworkspacetomonitor, l"
      "${hyprModifier} SHIFT, p, exec, flameshot gui"
      "${hyprModifier}, h, movefocus, l"
      "${hyprModifier}, l, movefocus, r"
      "${hyprModifier}, k, movefocus, u"
      "${hyprModifier}, j, movefocus, d"
      "${hyprModifier} SHIFT, h, movewindow, l"
      "${hyprModifier} SHIFT, l, movewindow, r"
      "${hyprModifier} SHIFT, k, movewindow, u"
      "${hyprModifier} SHIFT, j, movewindow, d"
      "${hyprModifier}, 1, workspace, 1"
      "${hyprModifier}, 2, workspace, 2"
      "${hyprModifier}, 3, workspace, 3"
      "${hyprModifier}, 4, workspace, 4"
      "${hyprModifier}, 5, workspace, 5"
      "${hyprModifier}, 6, workspace, 6"
      "${hyprModifier}, 7, workspace, 7"
      "${hyprModifier}, 8, workspace, 8"
      "${hyprModifier}, 9, workspace, 9"
      "${hyprModifier}, 0, workspace, 10"
      "${hyprModifier} SHIFT, 1, movetoworkspace, 1"
      "${hyprModifier} SHIFT, 2, movetoworkspace, 2"
      "${hyprModifier} SHIFT, 3, movetoworkspace, 3"
      "${hyprModifier} SHIFT, 4, movetoworkspace, 4"
      "${hyprModifier} SHIFT, 5, movetoworkspace, 5"
      "${hyprModifier} SHIFT, 6, movetoworkspace, 6"
      "${hyprModifier} SHIFT, 7, movetoworkspace, 7"
      "${hyprModifier} SHIFT, 8, movetoworkspace, 8"
      "${hyprModifier} SHIFT, 9, movetoworkspace, 9"
      "${hyprModifier} SHIFT, 0, movetoworkspace, 10"
      "${hyprModifier}, f, fullscreen,"
      "${hyprModifier} SHIFT, space, togglefloating,"
      "${hyprModifier}, mouse_down, workspace, e+1"
      "${hyprModifier}, mouse_up, workspace, e-1"
    ];
    mediaKeys = [
      ", XF86AudioRaiseVolume, exec, playerctl volume 0.05+"
      ", XF86AudioLowerVolume, exec, playerctl volume 0.05-"
      ", XF86AudioStop, exec, playerctl play-pause"
    ];
  };
in
{
  configuration = configuration // {
    i3 = i3Config;
    sway = swayConfig;
    hyprland = hyprlandConfig;
  };
}
