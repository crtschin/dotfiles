{ config, pkgs, inputs, ... }:
let
  nixGLOverlay = (self: super: {
    nixGLWrapper = program: pkgs.writeShellScriptBin program.pname ''
      #!/bin/sh
      ${self.nixgl.auto.nixGLDefault}/bin/nixGL ${program}/bin/${program.pname} "$@"
    '';
    nixGLIntelWrapper = program: pkgs.writeShellScriptBin program.pname ''
      #!/bin/sh
      ${self.nixgl.nixGLIntel}/bin/nixGLIntel ${program}/bin/${program.pname} "$@"
    '';
    myNixGL = self.nixGLIntelWrapper;

    picom = self.myNixGL super.picom;
    brave = self.myNixGL super.brave;
    kitty = self.myNixGL super.kitty;
    alacritty = self.myNixGL super.alacritty;
  });
in
{
  nixpkgs.overlays =
     [ nixGLOverlay ];
}
