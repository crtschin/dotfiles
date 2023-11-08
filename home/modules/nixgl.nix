{
  config,
  pkgs,
  inputs,
  ...
}: let
  nixGLOverlay = self: super: {
    overrideRPath = program: program.overrideAttrs ({ postInstall ? "", ... }: {
      postInstall = postInstall + ''
        LD_LIBRARY_PATH=$(bash -c "${self.nixgl.auto.nixGLDefault}/bin/nixGL printenv LD_LIBRARY_PATH")
        patchelf --set-rpath "$LD_LIBRARY_PATH" "$out/bin/${program.name}"
      '';
    });
    nixGLWrap = program:
      pkgs.writeShellScriptBin program.pname ''
        #!/bin/sh
        ${self.nixgl.auto.nixGLDefault}/bin/nixGL ${program}/bin/${program.pname} "$@"
      '';
    nixGLIntelWrap = program:
      pkgs.writeShellScriptBin program.pname ''
        #!/bin/sh

        export NIXGL_LIBVA_DRIVERS_PATH=$LIBVA_DRIVERS_PATH
        export NIXGL_LIBGL_DRIVERS_PATH=$LIBGL_DRIVERS_PATH
        export NIXGL_LD_LIBRARY_PATH=$LD_LIBRARY_PATH
        export NIXGL___EGL_VENDOR_LIBRARY_FILENAMES=$__EGL_VENDOR_LIBRARY_FILENAMES
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
  programs = {
    fish = {
      shellInit = ''
        set LIBVA_DRIVERS_PATH $NIXGL_LIBVA_DRIVERS_PATH
        set LIBGL_DRIVERS_PATH $NIXGL_LIBGL_DRIVERS_PATH
        set LD_LIBRARY_PATH $NIXGL_LD_LIBRARY_PATH
        set __EGL_VENDOR_LIBRARY_FILENAMES $NIXGL___EGL_VENDOR_LIBRARY_FILENAMES
        set -e NIXGL_LIBVA_DRIVERS_PATH NIXGL_LIBGL_DRIVERS_PATH NIXGL_LD_LIBRARY_PATH NIXGL___EGL_VENDOR_LIBRARY_FILENAMES
      '';
    };
  };
}
