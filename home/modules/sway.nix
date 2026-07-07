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
  # home-manager's own escape hatch for hosts where the user manager is the
  # distro's systemd rather than the one in this closure.
  systemctl = config.systemd.user.systemctlPath;
in
{
  home.packages =
    with pkgs;
    pkgs.onlyIfList enable [
      swaybg
      wl-clipboard
      grim
    ];

  # xdg-desktop-portal caches its environment for its whole lifetime. Activated
  # before sway publishes the session env, it comes up with an empty
  # XDG_CURRENT_DESKTOP, fails the `UseIn=sway` gate in wlr.portal, and exposes no
  # Screenshot interface, so callers hang rather than error. The exec in extraConfig
  # fixes the env for portals activated after sway starts. This unit covers one left
  # running from earlier in the login session.
  #
  # The frontend alone is enough. It re-activates the wlr backend on demand.
  systemd.user.services = pkgs.onlyIfAttrs enable {
    xdg-desktop-portal-reload = {
      Unit = {
        Description = "Restart xdg-desktop-portal with the sway session environment";
        After = [ "sway-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${systemctl} --user restart xdg-desktop-portal.service";
      };
      Install.WantedBy = [ "sway-session.target" ];
    };
  };

  # Nothing here defines sway-session.target, so a host missing its distro's
  # sway-systemd integration would boot into a session where waybar, kanshi and the
  # portal reload never start, with nothing to say why. Catch it at switch time.
  home.activation = pkgs.onlyIfAttrs enable {
    checkSwaySessionTarget = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if ! ${systemctl} --user list-unit-files sway-session.target > /dev/null 2>&1; then
        warnEcho "sway-session.target not found. Install your distro's sway-systemd integration, or waybar, kanshi and xdg-desktop-portal-reload will not start."
      fi
    '';
  };

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
        # Both hosts already bootstrap the session from /etc/sway/config.d, included
        # below: Fedora through sway-systemd's session.sh, NixOS through the
        # nixos.conf that programs.sway writes. Either one starts and stops
        # sway-session.target, so a home-manager copy would give it two supervisors.
        systemd.enable = false;
        wrapperFeatures = {
          gtk = false;
          base = true;
        };
        extraConfig = ''
          # sway never sets XDG_CURRENT_DESKTOP itself. NixOS' nixos.conf forwards it
          # by name from sway's environ, which a bare `exec sway` from a TTY leaves
          # unset, so nothing reaches the session env and wlr.portal's `UseIn=sway`
          # gate fails. Assign it outright, above the include: sway defers every
          # `exec` to one FIFO queue and forks each without waiting, so this must be
          # queued before the included file starts sway-session.target. Fedora's
          # session.sh exports the variable itself, making this a no-op there.
          exec ${lib.getExe' pkgs.dbus "dbus-update-activation-environment"} --systemd XDG_CURRENT_DESKTOP=sway

          include /etc/sway/config.d/*

          ${configuration.sway.colorTheme}
          smart_gaps on
          gaps inner 10

          # configuration.sway.assign and .workspaces are i3-shaped and unused here.
          # config.assigns below carries every `class` match those assigns had, plus
          # the app_id matches Wayland-native windows need. `output primary` and
          # `secondary` are i3 names, and kanshi pins workspaces to outputs instead.

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
            "3: web" = [
              { class = "Firefox"; }
              { instance = "brave-browser"; }
            ];
            # The `codes` aliases run `code` with no ozone flag, so VS Code comes up
            # as XWayland with WM_CLASS `Code` and no app_id.
            "1: code" = [
              { app_id = "code"; }
              { class = "Code"; }
            ];
          };
          fonts = configuration.sway.fonts;
          keybindings = configuration.sway.keybindings;
          startup = [
            { command = configuration.variables.terminal; }
            { command = "${pkgs.firefox}/bin/firefox"; }
            { command = "${pkgs.spotify}/bin/spotify"; }
          ];
          bars = [ ];
          modifier = configuration.variables.modifier;
          terminal = configuration.terminal.name;
        };
      };
    };
  };
}
