{
  config,
  pkgs,
  inputs,
  ...
}: let
  nixGLOverlay = self: super: {
    nixGLWrap = program:
      pkgs.writeShellScriptBin program.pname ''
        #!/bin/sh
        ${self.nixgl.auto.nixGLDefault}/bin/nixGL ${program}/bin/${program.pname} "$@"
      '';
    nixGLIntelWrap = program:
      pkgs.writeShellScriptBin program.pname ''
        #!/bin/sh
        ${self.nixgl.nixGLIntel}/bin/nixGLIntel ${program}/bin/${program.pname} "$@"
      '';
    myNixGLWrap = self.nixGLWrap;

    nixGL = self.nixgl.auto.nixGLDefault;
    picom = self.myNixGLWrap super.picom;
    brave = self.myNixGLWrap super.brave;
    kitty = self.myNixGLWrap super.kitty;
    alacritty = self.myNixGLWrap super.alacritty;
  };
in {
  nixpkgs.overlays = [nixGLOverlay];
}
