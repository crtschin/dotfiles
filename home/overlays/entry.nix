self: super:
let
  lib = super.lib;
in
rec {
  configuration = super.configuration // rec {
    terminal = {
      package = super.kitty;
      name = "kitty --single-instance";
    };
    rice = {
      brighten = 20;
      darken = 20;
    };
    variables = {
      modifier = "Mod4";
      terminal = "${terminal.package}/bin/${terminal.name}";
    };
    flags = rec {
      sway = super.configuration.wm == "sway";
      hyprland = super.configuration.wm == "hyprland";
      i3 = super.configuration.wm == "i3";
      protocol = {
        x = i3;
        wayland = i3 || hyprland || sway;
      };
    };
  };

  # * Utilities

  assertOneOfSet =
    set:
    let
      vals = lib.attrsets.attrValues set;
      keys = lib.attrNames set;
    in
    lib.asserts.assertMsg (lib.lists.findSingle (b: b) false false vals) ''
      Expected one of ${lib.strings.concatStringsSep ", " keys} to be true.
        Received ${lib.strings.concatStringsSep ", " (map toString vals)}
    '';

  onlyIfAttrs = b: set: if b then set else { };
  onlyIfList = b: set: if b then set else [ ];

  # Usage notice, install wrapped packages in `/usr/bin`
  nativeWrapper =
    program:
    super.writeShellScriptBin program.pname ''
      PATH=/usr/bin:${program}/bin ${program.pname} "$@"
    '';

  # * Actual overrides

  monitor-heap = super.writeShellScriptBin "monitor-heap" ''
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

  flameshot = super.flameshot.override {
    enableWlrSupport = configuration.flags.protocol.wayland;
  };
}
