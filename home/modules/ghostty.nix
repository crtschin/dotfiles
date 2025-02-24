{
  config,
  pkgs,
  inputs,
  ...
}:
let
  palette = pkgs.riceExtendedColorPalette;
in
{
  programs = {
    ghostty = {
      enable = true;
      enableFishIntegration = true;
      installBatSyntax = true;
      settings = {
        theme = "my-gruvbox";
        font-size = pkgs.rice.font.monospace.size;
        font-family = pkgs.rice.font.monospace.name;
        command = "${pkgs.fish}/bin/fish";
      };
      themes = {
        my-gruvbox = {
          palette = [
            "0=${palette.color0}"
            "1=${palette.color1}"
            "2=${palette.color2}"
            "3=${palette.color3}"
            "4=${palette.color4}"
            "5=${palette.color5}"
            "6=${palette.color6}"
            "7=${palette.color7}"
            "8=${palette.color8}"
            "9=${palette.color9}"
            "10=${palette.color10}"
            "11=${palette.color11}"
            "12=${palette.color12}"
            "13=${palette.color13}"
            "14=${palette.color14}"
            "15=${palette.color15}"
          ];
          background = "${palette.primary.background}";
          foreground = "${palette.primary.foreground}";
          cursor-color = "${palette.primary.foreground}";
          cursor-text = "${palette.primary.foreground}";
          selection-background = "${palette.primary.foreground}";
          selection-foreground = "${palette.primary.background}";
        };
      };
    };
  };
}
