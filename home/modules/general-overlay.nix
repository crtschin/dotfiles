{
  config,
  pkgs,
  inputs,
  ...
}:
let
  overlay = self: super: {
    # Usage notice, install wrapped packages in `/usr/bin`
    native_wrapper =
      program:
      pkgs.writeShellScriptBin program.pname ''
        PATH=/usr/bin:${program}/bin ${program.pname} "$@"
      '';

    monitor-heap = pkgs.writeShellScriptBin "monitor-heap" ''
      #!/bin/sh
      head -`fgrep -n END_SAMPLE $1.hp | tail -1 | cut -d : -f 1` $1.hp \
        | hp2ps > $1.ps
      gv $1.ps &
      gvpsnum=$!
      while [ 1 ] ; do
        sleep 10
        head -`fgrep -n END_SAMPLE $1.hp | tail -1 | cut -d : -f 1` $1.hp \
          | hp2ps > $1.ps
        kill -HUP $gvpsnum
      done
    '';

    # https://github.com/NixOS/nixpkgs/issues/292700https://github.com/NixOS/nixpkgs/issues/292700
    flameshotGrim = pkgs.flameshot.overrideAttrs (oldAttrs: {
      src = pkgs.fetchFromGitHub {
        owner = "flameshot-org";
        repo = "flameshot";
        rev = "3d21e4967b68e9ce80fb2238857aa1bf12c7b905";
        sha256 = "sha256-OLRtF/yjHDN+sIbgilBZ6sBZ3FO6K533kFC1L2peugc=";
      };
      cmakeFlags = [
        "-DUSE_WAYLAND_CLIPBOARD=1"
        "-DUSE_WAYLAND_GRIM=1"
      ];
      buildInputs = oldAttrs.buildInputs ++ [ pkgs.libsForQt5.kguiaddons ];
    });
  };
in
{
  nixpkgs.overlays = [ overlay ];
}
