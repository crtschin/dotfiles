self: super:
with self.lib.nix-rice; let
  _themePathToThemeName = path: let
    file_name = builtins.baseNameOf path;
    theme_name = builtins.head (builtins.match "(.+)\.conf$" file_name);
  in
    theme_name;

  _themeNameToThemePath = name: let
  in "${self.kitty-themes}/share/kitty-themes/themes/${name}.conf";
in {
  # Modified from the following to change the path to the theme
  # https://github.com/bertof/nix-rice/blob/main/kitty-themes.nix
  kittyParseUtils = rec {
    parseTheme = path: let
      file_contents = self.lib.strings.fileContents path;
      file_lines = self.lib.strings.splitString "\n" file_contents;
      line_parser = builtins.match " *([A-z0-9_]+) +(#[A-z0-9_]+) *";
      result_filter = r: builtins.isList r && builtins.length r == 2;
      result_mapper = r: let
        key = builtins.head r;
        value = color.hexToRgba (self.lib.lists.last r);
      in {"${key}" = value;};
    in
      builtins.foldl' self.lib.attrsets.recursiveUpdate {} (
        builtins.map result_mapper (
          builtins.filter result_filter (
            builtins.map line_parser file_lines
          )
        )
      );

    getThemeByName = name: parseTheme (_themeNameToThemePath name);
    riceKittyTheme = getThemeByName "GruvboxMaterialDarkSoft";
  };

  riceRgbColorPalette = with self.rice.colorPalette;
    self.lib.nix-rice.palette.toRgbHex rec {
      inherit
        color0
        color1
        color2
        color3
        color4
        color5
        color6
        color7
        color8
        color9
        color10
        color11
        color12
        color13
        color14
        color15
        background
        foreground
        cursor
        selection_background
        selection_foreground
        normal
        bright
        dark
        primary
        ;
    };
  rice = with self.kittyParseUtils.riceKittyTheme; rec {
    colorPalette =
      rec {
        normal =
          palette.defaultPalette
          // {
            black = color0;
            red = color1;
            green = color2;
            yellow = color3;
            blue = color4;
            magenta = color5;
            cyan = color6;
            white = color7;
          };
        bright =
          palette.brighten 10 normal
          // {
            black = color8;
            red = color9;
            green = color10;
            yellow = color11;
            blue = color12;
            magenta = color13;
            cyan = color14;
            white = color15;
          };
        dark = palette.darken 10 normal;
        primary = {
          inherit background foreground;
          theme = riceKittyTheme;
          bright_foreground = color.brighten 10 riceKittyTheme.foreground;
          dim_foreground = color.darken 10 riceKittyTheme.foreground;
        };
      }
      // self.kittyParseUtils.riceKittyTheme;
    font = {
      normal = {
        name = "Cantarell";
        package = self.cantarell-fonts;
        size = 10;
      };
      monospace = {
        name = "FiraCode";
        package = self.fira-code;
        size = 10;
      };
    };
    opacity = 0.95;
  };
}
