{
  config,
  pkgs,
  inputs,
  ...
}:
let

in
{
  programs = {
    kitty = {
      enable = true;
      font = {
        name = pkgs.rice.font.normal.name;
        size = 14;
      };
      settings = {
        allow_remote_control = true;
        clear_all_shortcuts = true;
        copy_on_select = true;
        cursor_shape = "block";
        cursor_trail = 3;
        cursor_trail_decay = "0.1 0.4";
        disable_ligatures = "cursor";
        enable_audio_bell = true;
        scrollback_lines = 10000;
        shell = "${pkgs.fish}/bin/fish";
        shell_integration = "no-cursor";
        strip_trailing_spaces = "always";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        update_check_interval = 0;
        visual_bell_duration = "0.5";
      }
      // pkgs.riceColorPalette;
      quickAccessTerminalConfig = { };
      keybindings = {
        "ctrl+c" = "copy_or_interrupt";
        "ctrl+shift+c" = "copy_to_clipboard";
        "ctrl+shift+v" = "paste_from_clipboard";

        "alt+up" = "scroll_line_up";
        "alt+down" = "scroll_line_down";
        "alt+k" = "scroll_line_up";
        "alt+j" = "scroll_line_down";
        "alt+page_up" = "scroll_page_up";
        "alt+page_down" = "scroll_page_down";
        "alt+home" = "scroll_home";
        "alt+end" = "scroll_end";
        "alt+h" = "show_scrollback";

        "ctrl+up" = "next_tab";
        "ctrl+down" = "previous_tab";
        "ctrl+k" = "next_tab";
        "ctrl+j" = "previous_tab";
        "ctrl+t" = "new_tab";
        "ctrl+w" = "close_tab";
        "ctrl+n" = "new_window_with_cwd";
        "ctrl+x" = "close_window";
        "ctrl+right" = "next_window";
        "ctrl+left" = "previous_window";
        "ctrl+equal" = "change_font_size all +2.0";
        "ctrl+minus" = "change_font_size all -2.0";
      };
    };
  };
}
