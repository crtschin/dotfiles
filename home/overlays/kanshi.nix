self: super:
let
  lib = super.lib;
in
rec {
  createKanshiName = monitor: lib.strings.toLower (builtins.replaceStrings [ " " ] [ "_" ] monitor);

  createKanshiProfile =
    {
      criteria,
      x,
      y,
      width,
      height,
      enable ? true,
    }:
    {
      status = if enable then "enable" else "disable";
      inherit criteria;
      position = "${toString x},${toString y}";
      mode = "${toString width}x${toString height}";
    };

  createDockedProfile =
    {
      monitor,
      width,
      height,
      side,
    }:
    let
      laptopProfile = {
        criteria = "eDP-1";
        height = 1200;
        width = 1920;
      };
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
            "exec swaymsg workspace 1, move workspace to \"'${monitorProfile.criteria}'\""
            "exec swaymsg workspace 2, move workspace to \"'${laptopProfile.criteria}'\""
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
        criteria = "eDP-1";
        inherit (laptop) x y enable;
        width = 1920;
        height = 1200;
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
          (
            if laptop.enable == true then [ "exec swaymsg workspace 10, move workspace to \"eDP-1\"" ] else [ ]
          )
          ++ [
            "exec swaymsg workspace 1, move workspace to \"'${left.criteria}'\""
            "exec swaymsg workspace 2, move workspace to \"'${right.criteria}'\""
          ];
      };
    };
}
