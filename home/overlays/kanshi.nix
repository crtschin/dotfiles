self: super:
let
  lib = super.lib;
  # kanshi.service runs with an empty Environment, so it inherits the systemd user
  # manager PATH, which has no Nix profile on it.
  swaymsg = lib.getExe' self.sway "swaymsg";
in
rec {
  createKanshiName = monitor: lib.strings.toLower (builtins.replaceStrings [ " " ] [ "_" ] monitor);

  # The laptop panel, so every profile and the presentation fallback agree on one
  # set of dimensions.
  kanshiLaptopOutput = {
    criteria = "eDP-1";
    width = 1920;
    height = 1200;
  };

  # kanshi's `*` wildcard is not a sway output name, so the fallback profile cannot
  # use the `move workspace to "'<criteria>'"` form below. `to output right` is also
  # wrong: output_in_direction in sway/commands/move.c falls back to
  # wlr_output_layout_farthest_output in the opposite direction when nothing lies
  # that way, so once the workspace already sits on the rightmost output it wraps
  # back onto the laptop.
  moveWorkspaceToExternalOutput = self.writeShellApplication {
    name = "kanshi-move-workspace-to-external-output";
    runtimeInputs = [
      self.sway
      self.jq
    ];
    text = ''
      external=$(swaymsg -t get_outputs \
        | jq -r --arg laptop ${lib.escapeShellArg kanshiLaptopOutput.criteria} \
            'first(.[] | select(.active and .name != $laptop) | .name)')
      if [ -n "$external" ]; then
        swaymsg workspace "$1", move workspace to output "$external"
      fi
    '';
  };

  # Omitting width/height omits `mode`, letting the output come up at its preferred
  # resolution. Needed for the wildcard fallback, whose resolution is unknown.
  createKanshiProfile =
    {
      criteria,
      x,
      y,
      width ? null,
      height ? null,
      enable ? true,
    }:
    {
      status = if enable then "enable" else "disable";
      inherit criteria;
      position = "${toString x},${toString y}";
    }
    // lib.optionalAttrs (width != null) { mode = "${toString width}x${toString height}"; };

  createDockedProfile =
    {
      monitor,
      width,
      height,
      side,
    }:
    let
      laptopProfile = kanshiLaptopOutput;
      monitorProfile = {
        criteria = monitor;
        inherit height width;
      };
    in
    if side == "up" then
      # Vertical stack: monitor on top, laptop below, centred on the shared horizontal axis.
      let
        maxWidth = lib.max monitorProfile.width laptopProfile.width;
      in
      {
        profile = {
          name = createKanshiName "docked_${monitorProfile.criteria}_up";
          outputs = [
            (createKanshiProfile {
              criteria = monitorProfile.criteria;
              x = (maxWidth - monitorProfile.width) / 2;
              y = 0;
              width = monitorProfile.width;
              height = monitorProfile.height;
            })
            (createKanshiProfile {
              criteria = laptopProfile.criteria;
              x = (maxWidth - laptopProfile.width) / 2;
              y = monitorProfile.height;
              width = laptopProfile.width;
              height = laptopProfile.height;
            })
          ];
          exec = [
            "${swaymsg} workspace 1, move workspace to \"'${monitorProfile.criteria}'\""
            "${swaymsg} workspace 2, move workspace to \"'${laptopProfile.criteria}'\""
          ];
        };
      }
    else
      # Horizontal: the laptop sits on whichever side the monitor does not.
      let
        canonicallyLeft = if side == "left" then monitorProfile else laptopProfile;
        canonicallyRight = if side == "left" then laptopProfile else monitorProfile;
      in
      createDualDockedProfile {
        left = canonicallyLeft;
        right = canonicallyRight;
        laptop = {
          enable = null;
          x = 0;
          y = 0;
        };
      };

  createDualDockedIdenticalProfile =
    {
      left,
      right,
      width,
      height,
      laptop ? {
        enable = false;
        x = 0;
        y = 0;
      },
    }:
    createDualDockedProfile {
      left = {
        criteria = left;
        inherit width height;
      };
      right = {
        criteria = right;
        inherit width height;
      };
      inherit laptop;
    };

  # Two side-by-side monitors with the laptop's eDP-1 as an optional third output.
  # laptop.enable tri-state:
  #   null  -> omit the laptop output entirely (it is already one of left/right)
  #   false -> include the laptop output but disabled
  #   true  -> include it enabled and pin workspace 10 to it
  createDualDockedProfile =
    {
      left,
      right,
      laptop,
    }:
    let
      laptopProfile = createKanshiProfile {
        inherit (laptop) x y enable;
        inherit (kanshiLaptopOutput) criteria width height;
      };
    in
    {
      profile = {
        name = createKanshiName "docked_dual_${left.criteria}_${right.criteria}";
        outputs = (if laptop.enable == null then [ ] else [ laptopProfile ]) ++ [
          (createKanshiProfile {
            criteria = right.criteria;
            x = left.width;
            y = 0;
            width = right.width;
            height = right.height;
          })
          (createKanshiProfile {
            criteria = left.criteria;
            x = 0;
            y = 0;
            width = left.width;
            height = left.height;
          })
        ];
        exec =
          (if laptop.enable == true then [ "${swaymsg} workspace 10, move workspace to \"eDP-1\"" ] else [ ])
          ++ [
            "${swaymsg} workspace 1, move workspace to \"'${left.criteria}'\""
            "${swaymsg} workspace 2, move workspace to \"'${right.criteria}'\""
          ];
      };
    };
}
