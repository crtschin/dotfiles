{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  nixGLOverlay = self: super: let
    nixGLPrefix = "${self.nixgl.auto.nixGLDefault}/bin/nixGL";
  in {
    nixGLWrap114 = pkg: (pkg.overrideAttrs (old: {
      name = "nixGL-${pkg.name}";
      buildCommand = ''
        set -eo pipefail

        ${
          # Heavily inspired by https://stackoverflow.com/a/68523368/6259505
          pkgs.lib.concatStringsSep "\n" (map (outputName: ''
            echo "Copying output ${outputName}"
            set -x
            cp -rs --no-preserve=mode "${pkg.${outputName}}" "''$${outputName}"
            set +x
          '') (old.outputs or ["out"]))
        }

        rm -rf $out/bin/*
        shopt -s nullglob # Prevent loop from running if no files
        for file in ${pkg.out}/bin/*; do
          echo "#!${pkgs.bash}/bin/bash" > "$out/bin/$(basename $file)"
          echo "exec -a \"\$0\" ${nixGLPrefix} $file \"\$@\"" >> "$out/bin/$(basename $file)"
          chmod +x "$out/bin/$(basename $file)"
        done
        shopt -u nullglob # Revert nullglob back to its normal default state
      '';
    }));

    overrideRPath = program:
      program.overrideAttrs ({postInstall ? "", ...}: {
        postInstall =
          postInstall
          + ''
            LD_LIBRARY_PATH=$(bash -c "${self.nixgl.auto.nixGLDefault}/bin/nixGL printenv LD_LIBRARY_PATH")
            patchelf --set-rpath "$LD_LIBRARY_PATH" "$out/bin/${program.name}"
          '';
      });
    nixGLWrap = program:
      pkgs.writeShellScriptBin program.pname ''
        #!/bin/sh
        ${self.nixgl.auto.nixGLDefault}/bin/nixGL ${program}/bin/${program.pname} "$@"
      '';
    nixGLWrapIntel = program:
      pkgs.writeShellScriptBin program.pname ''
        #!/bin/sh
        ${self.nixgl.nixGLIntel}/bin/nixGLIntel ${program}/bin/${program.pname} "$@"
      '';
    myNixGLWrap = self.nixGLWrap114;

    nixGL = self.nixgl.auto.nixGLDefault;
    picom = self.myNixGLWrap super.picom;
    brave = self.myNixGLWrap super.brave;
    kitty = self.myNixGLWrap super.kitty;
    alacritty = self.myNixGLWrap super.alacritty;
  };
in {
  nixpkgs.overlays = [nixGLOverlay];
  home = {
    packages = with pkgs; [
      nixGL
    ];
  };
  programs = {
    fish = {
      shellAliases = {
        # code = "nixGLIntel code";
      };
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
