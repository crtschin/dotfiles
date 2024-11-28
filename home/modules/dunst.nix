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
          font = "${pkgs.rice.font.monospace.name} 12";
          allow_markup = "yes";
          format = "<b>%s</b>\n%b";
          sort = "yes";
          indicate_hidden = "yes";
          alignment = "center";
          bounce_freq = 0;
          show_age_threshold = 60;
          word_wrap = "yes";
          ignore_newline = "no";
          geometry = "200x5-6+30";
          transparency = 0;
          idle_threshold = 120;
          monitor = 0;
          follow = "mouse";
          sticky_history = "yes";
          line_height = 0;
          separator_height = 2;
          padding = 8;
          horizontal_padding = 8;
          separator_color = "#585858";
          startup_notification = false;
        };
        frame = {
          width = 1;
          color = "#83a598";
        };
        shortcuts = {
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
