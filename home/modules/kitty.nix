{ config, pkgs, inputs, ... }:
let
  strPalette = with pkgs.rice.colorPalette;
    pkgs.lib.nix-rice.palette.toRgbHex rec {
      inherit color0 color1 color2 color3 color4 color5 color6 color7 color8
      color9 color10 color11 color12 color13 color14 color15
      background foreground cursor selection_background selection_foreground;
    };
in {
  programs = {
    fish = {
      shellAliases = {
        kdiff = "kitty +kitten diff -o pygments_style=gruvbox-dark";
        kssh = "kitty +kitten ssh";
        kicat = "kitty +kitten icat";
      };
    };
    kitty = {
      enable = true;
      font = {
        name = "Fira Code";
        size = 14;
      };
      settings = {
        disable_ligatures = "cursor";
        scrollback_lines = 10000;
        copy_on_select = true;
        strip_trailing_spaces = "always";
        cursor_shape = "block";
        enable_audio_bell = true;
        visual_bell_duration = "0.5";
        shell = "${pkgs.fish}/bin/fish";
        clear_all_shortcuts = true;
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
      } // strPalette;
      keybindings = {
        "ctrl+c" = "copy_or_interrupt";
        "ctrl+shift+c" = "copy_to_clipboard";
        "ctrl+shift+v" = "paste_from_clipboard";
        "shift+insert" = "paste_from_clipboard";
        "ctrl+s" = "paste_from_selection";

        "alt+up" = "scroll_line_up";
        "alt+down" = "scroll_line_down";
        "alt+page_up" = "scroll_page_up";
        "alt+page_down" = "scroll_page_down";
        "alt+home" = "scroll_home";
        "alt+end" = "scroll_end";
        "alt+h" = "show_scrollback";

        "ctrl+up" = "next_tab";
        "ctrl+down" = "previous_tab";
        "ctrl+t" = "new_tab";
        "ctrl+w" = "close_tab";
        "ctrl+n" = "new_window";
        "ctrl+x" = "close_window";
        "ctrl+right" = "next_window";
        "ctrl+left" = "previous_window";
        "ctrl+equal" = "change_font_size all +2.0";
        "ctrl+minus" = "change_font_size all -2.0";
      };
    };
  };
}
