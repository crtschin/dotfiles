{
  lib,
  pkgs,
  ...
}:
let
  configuration = pkgs.configuration;
  rgbTheme = pkgs.riceExtendedColorPalette;
  modifier = "SUPER";
  enable = configuration.flags.hyprland or false;
in
{
  # Install packages only when hyprland is enabled
  home.packages =
    with pkgs;
    pkgs.onlyIfList enable [
      waybar        # Status bar (shared with sway)
      wl-clipboard  # Wayland clipboard utilities
      grim          # Screenshot utility for Wayland
      hyprpaper     # Wallpaper daemon for Hyprland
      hyprlauncher  # Application launcher for Hyprland
    ];

  programs = {
    # Status bar configuration (shared with sway)
    waybar = {
      inherit enable;
    };
  };

  # Hyprlauncher service with gruvbox theming
  services.hyprlauncher = {
    enable = enable;
    settings = {
      # General settings
      general = {
        # Grab keyboard focus when opening
        grab_focus = true;
        # Show icons in results
        show_icons = true;
      };

      # Cache for faster application loading
      cache = {
        enabled = true;
      };

      # UI configuration
      ui = {
        # Window size: width height
        window_size = "500 300";
        # Border radius (0 to match hyprland sharp borders)
        border_radius = 0;
        # Border width (2px to match hyprland)
        border_width = 2;
      };

      # Color scheme matching gruvbox theme
      colors = {
        # Background color
        background = rgbTheme.background;
        # Foreground text color
        foreground = rgbTheme.foreground;
        # Border color (green to match active hyprland border)
        border = rgbTheme.normal.green;
        # Selected item background
        selected_bg = rgbTheme.normal.green;
        # Selected item foreground
        selected_fg = rgbTheme.normal.black;
      };

      # Font configuration
      font = {
        # Font family matching system monospace font
        family = pkgs.rice.font.monospace.name;
        # Font size
        size = pkgs.rice.font.monospace.size;
      };

      # Finder configuration
      finders = {
        # Prefix for calculator mode
        math_prefix = "=";
        # Show desktop application icons
        desktop_icons = true;
      };
    };
  };

  wayland = {
    windowManager = {
      hyprland = {
        inherit enable;
        # Enable XWayland for compatibility with X11 applications (e.g., some legacy apps)
        xwayland.enable = true;
        # Enable systemd integration for proper session management and service startup
        systemd.enable = true;

        settings = {
          # Monitor configuration: use preferred resolution and auto-position with scale 1
          monitor = ",preferred,auto,1";

          # Workspace to monitor assignments from overlay (matches sway workspace configuration)
          workspace = configuration.hyprland.workspaceAssignments;

          # Window rules for automatic workspace assignment (Code→1, Firefox/Brave→2, Spotify→9)
          windowrulev2 = configuration.hyprland.windowRules;

          # Commands to execute once at startup
          exec-once = [
            # Update environment for systemd services to recognize Wayland session
            "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland"
            # Start terminal on launch (matching sway behavior)
            "${configuration.variables.terminal}"
            # Start wallpaper daemon
            "hyprpaper"
          ];

          # Environment variables to set for the session
          env = [
            # Enable Wayland support for Electron/Chrome-based apps
            "NIXOS_OZONE_WL,1"
          ];

          # Input device configuration
          input = {
            # Focus follows mouse cursor (value 1 = yes)
            follow_mouse = 1;
          };

          # General window manager settings
          general = {
            # Inner gaps between windows (10px, matching sway)
            gaps_in = 10;
            # Outer gaps between windows and monitor edges (10px)
            gaps_out = 10;
            # Window border width (2px, matching sway)
            border_size = 2;
            # Active window border color (green from gruvbox theme)
            "col.active_border" = "rgb(${lib.strings.removePrefix "#" rgbTheme.normal.green})";
            # Inactive window border color (dark gray from gruvbox theme)
            "col.inactive_border" = "rgb(${lib.strings.removePrefix "#" rgbTheme.normal.black})";
            # Use dwindle layout (similar to i3/sway tiling behavior)
            layout = "dwindle";
          };

          # Window decoration settings
          decoration = {
            # No rounded corners (matching sway's sharp aesthetic)
            rounding = 0;
            blur = {
              # Disable blur for performance and clean look
              enabled = false;
            };
            # Disable drop shadows for minimal appearance
            drop_shadow = false;
          };

          # Animation settings
          animations = {
            # Enable animations for smoother transitions
            enabled = true;
            # Custom bezier curve for smooth easing
            bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
            animation = [
              # Window open/close animation (3 deciseconds with custom bezier)
              "windows, 1, 3, myBezier"
              # Window close animation with slight shrink effect
              "windowsOut, 1, 3, default, popin 80%"
              # Border color transition animation
              "border, 1, 5, default"
              # Window fade in/out animation
              "fade, 1, 3, default"
              # Workspace switching animation
              "workspaces, 1, 3, default"
            ];
          };

          # Dwindle layout specific settings (primary layout)
          dwindle = {
            # Allow windows to be pseudotiled (floating-like but still tiled)
            pseudotile = true;
            # Remember which side of the split was selected
            preserve_split = true;
            # Disable automatic split direction based on window ratio
            smart_split = false;
          };

          # Master layout specific settings (alternative layout)
          master = {
            # New windows become the master window by default
            new_status = "master";
          };

          # Miscellaneous settings
          misc = {
            # Don't use Hyprland's default wallpaper (we use hyprpaper)
            force_default_wallpaper = 0;
            # Hide Hyprland logo on startup
            disable_hyprland_logo = true;
          };

          # Keybindings from overlay (launcher, terminal, workspaces, etc.)
          bind = configuration.hyprland.keybindings modifier;

          # Mouse bindings for window manipulation
          bindm = [
            # Left click + modifier to move windows
            "${modifier}, mouse:272, movewindow"
            # Right click + modifier to resize windows
            "${modifier}, mouse:273, resizewindow"
          ];

          # Media key bindings from overlay (volume, playback control)
          bindl = configuration.hyprland.mediaKeys;
        };

        # Additional configuration not covered by settings
        extraConfig = ''
          # Set cursor (empty string uses system default, size 24)
          exec = hyprctl setcursor "" 24
        '';
      };
    };
  };

  # Hyprpaper service for wallpaper management
  services.hyprpaper = {
    enable = enable;
    settings = {
      # Preload wallpaper into memory for faster switching
      preload = [ "~/Pictures/Wallpapers/background.png" ];
      # Apply wallpaper to all monitors (empty string before comma = all)
      wallpaper = [ ",~/Pictures/Wallpapers/background.png" ];
      # Disable splash screen on startup
      splash = false;
    };
  };
}
