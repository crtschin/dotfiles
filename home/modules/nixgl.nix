{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  nixGLOverlay = self: super: {
    brave = config.lib.nixGL.wrap super.brave;
    firefox = config.lib.nixGL.wrap super.firefox;
    kitty = config.lib.nixGL.wrap super.kitty;
    alacritty = config.lib.nixGL.wrap super.alacritty;
  };
in
{
  nixpkgs.overlays = [ nixGLOverlay ];
  targets.genericLinux = {
    nixGL = {
      packages = inputs.nixgl.packages;
      defaultWrapper = "mesa";
      offloadWrapper = "mesaPrime";
      installScripts = [
        "mesa"
        "mesaPrime"
      ];
    };
  };
}
