{
  config,
  pkgs,
  inputs,
  ...
}: let
in {
  programs = {
    alacritty = {
      enable = true;
      settings = {
        colors = {
          primary = {
            background = "0x282828";
            foreground = "0xdfbf8e";
          };
          normal = {
            black = "0x665c54";
            red = "0xea6962";
            green = "0xa9b665";
            yellow = "0xe78a4e";
            blue = "0x7daea3";
            magenta = "0xd3869b";
            cyan = "0x89b482";
            white = "0xdfbf8e";
          };
          bright = {
            black = "0x928374";
            red = "0xea6962";
            green = "0xa9b665";
            yellow = "0xe3a84e";
            blue = "0x7daea3";
            magenta = "0xd3869b";
            cyan = "0x89b482";
            white = "0xdfbf8e";
          };
        };
        font = {
          normal.family = "${pkgs.rice.font.monospace.name}";
          normal.style = "Regular";
          bold.family = "${pkgs.rice.font.monospace.name}";
          bold.style = "Bold";
          italic.family = "${pkgs.rice.font.monospace.name}";
          italic.style = "Light Italic";
          size = 13;
        };
        mouse = {
          double_click = {threshold = 300;};
          triple_click = {threshold = 300;};
          hide_when_typing = true;
        };
        selection = {
          semantic_escape_chars = ",│`|:\"' ()[]{}<>";
          save_to_clipboard = false;
        };
        mouse_bindings = [
          {
            mouse = "Middle";
            action = "PasteSelection";
          }
        ];
        cursor = {
          style = "Block";
          unfocused_hollow = true;
        };
        shell = {
          program = "${pkgs.fish}/bin/fish";
          args = ["--command=${pkgs.tmux}/bin/tmux"];
        };
      };
    };
  };
}
