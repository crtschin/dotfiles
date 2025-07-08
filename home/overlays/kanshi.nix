self: super:
let
  lib = super.lib;
  pkgs = super.pkgs;
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
      criteria = criteria;
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
        height = "1200";
        width = "1920";
      };
      monitorProfile = {
        criteria = monitor;
        height = height;
        width = width;
      };
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
      leftCriteria,
      rightCriteria,
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
        criteria = leftCriteria;
        width = width;
        height = height;
      };
      right = {
        criteria = rightCriteria;
        width = width;
        height = height;
      };
      laptop = laptop;
    };
  createDualDockedProfile =
    monitors:
    let
      laptopProfile = pkgs.createKanshiProfile {
        criteria = "eDP-1";
        x = monitors.laptop.x;
        y = monitors.laptop.y;
        enable = monitors.laptop.enable;
        width = 1920;
        height = 1200;
      };
    in
    {
      profile = {
        name = pkgs.createKanshiName "docked_dual_${monitors.left.criteria}_${monitors.right.criteria}";
        outputs = (if monitors.laptop.enable == null then [ ] else [ laptopProfile ]) ++ [
          (pkgs.createKanshiProfile {
            criteria = monitors.right.criteria;
            x = monitors.left.width;
            y = 0;
            width = monitors.right.width;
            height = monitors.right.height;
          })
          (pkgs.createKanshiProfile {
            criteria = monitors.left.criteria;
            x = 0;
            y = 0;
            width = monitors.left.width;
            height = monitors.left.height;
          })
        ];
        exec =
          (
            if monitors.laptop.enable == true then
              [ "exec swaymsg workspace 10, move workspace to \"eDP-1\"" ]
            else
              [ ]
          )
          ++ [
            "exec swaymsg workspace 1, move workspace to \"'${monitors.left.criteria}'\""
            "exec swaymsg workspace 2, move workspace to \"'${monitors.right.criteria}'\""
          ];
      };
    };
}
