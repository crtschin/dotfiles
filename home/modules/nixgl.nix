{ config, pkgs, lib, inputs, ... }:
let
  nixGLOverlay = self: super: {
    picom = config.lib.nixGL.wrap super.picom;
    brave = config.lib.nixGL.wrap super.brave;
    kitty = config.lib.nixGL.wrap super.kitty;
    alacritty = config.lib.nixGL.wrap super.alacritty;
  };
in {
  nixpkgs.overlays = [ nixGLOverlay ];
  nixGL.packages = inputs.nixgl.packages;
  nixGL.defaultWrapper = "mesa";
  nixGL.offloadWrapper = "mesaPrime";
  nixGL.installScripts = [ "mesa" "mesaPrime" ];
  home.packages = [ ];
}
