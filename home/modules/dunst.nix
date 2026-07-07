{
  config,
  pkgs,
  inputs,
  ...
}:
let
in
{
  services = {
    dunst = {
      enable = true;
      settings = {
        global = {
          # Deliberately larger than rice's monospace size: notifications are read
          # at a glance from across the room, not leaned into like a terminal.
          font = "${pkgs.rice.font.monospace.name} 14";
          markup = "full";
          # dunst parses the escape itself. A real newline here would split the
          # value across two lines and break parsing.
          format = "<b>%s</b>\\n%b";
          sort = "yes";
          indicate_hidden = "yes";
          alignment = "center";
          show_age_threshold = 60;
          word_wrap = "yes";
          ignore_newline = "no";
          # Replaces the pre-1.7 `geometry = "200x5-6+30"`, whose height field was a
          # notification count and whose negative x meant right-anchored.
          # A `(min, max)` range lets the box grow to fit the body; a bare int
          # pins it and wraps long messages into a sliver.
          width = "(300, 550)";
          notification_limit = 5;
          origin = "top-right";
          offset = "(6, 30)";
          transparency = 0;
          idle_threshold = 120;
          # `follow` overrides `monitor`, so monitor is omitted.
          follow = "mouse";
          sticky_history = "yes";
          line_height = 0;
          separator_height = 2;
          padding = 8;
          horizontal_padding = 8;
          separator_color = "#585858";
          frame_width = 1;
          frame_color = "#83a598";
          # dunst grabs these through X11, so under sway they do nothing. Bind
          # dunstctl in the compositor instead.
          close = "ctrl+space";
          close_all = "ctrl+shift+space";
          history = "ctrl+grave";
          context = "ctrl+shift+period";
        };
        urgency_low = {
          background = "#282828";
          foreground = "#ebdbb2";
          timeout = 5;
        };
        urgency_normal = {
          background = "#282828";
          foreground = "#ebdbb2";
          timeout = 20;
        };
        urgency_critical = {
          background = "#282828";
          foreground = "#ebdbb2";
          timeout = 0;
        };
      };
    };
  };
}
