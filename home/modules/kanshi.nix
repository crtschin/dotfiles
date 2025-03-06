{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  enableWayland = pkgs.useWayland;
  fixMonitorName = monitor: lib.strings.toLower (builtins.replaceStrings [ " " ] [ "_" ] monitor);
  createLeftDockedProfile =
    monitor:
    let
      monitor' = fixMonitorName monitor;
    in
    {
      profile = {
        name = "docked_left_${monitor'}";
        outputs = [
          {
            criteria = "eDP-1";
            position = "0,0";
            mode = "1920x1200";
          }
          {
            criteria = monitor;
            position = "1920,0";
            mode = "2560x1440";
          }
        ];
        exec = [
          "exec swaymsg workspace 10, move workspace to \"eDP-1\""
          "exec swaymsg workspace 1, move workspace to \"'${monitor}'\""
          "exec swaymsg workspace 2, move workspace to \"'${monitor}'\""
        ];
      };
    };
  createDualDockedIdenticalProfile =
    monitors:
    createDualDockedProfile {
      left = {
        criteria = monitors.left_criteria;
        width = monitors.width;
        height = monitors.height;
      };
      right = {
        criteria = monitors.right_criteria;
        width = monitors.width;
        height = monitors.height;
      };
    };
  createDualDockedProfile =
    monitors:
    let
      left' = fixMonitorName monitors.left.criteria;
      right' = fixMonitorName monitors.right.criteria;
    in
    {
      profile = {
        name = "docked_left_${left'}_${right'}";
        outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = monitors.left.criteria;
            position = "0,0";
            mode = "${toString monitors.left.width}x${toString monitors.left.height}";
          }
          {
            criteria = monitors.right.criteria;
            position = "${toString monitors.left.width},0";
            mode = "${toString monitors.right.width}x${toString monitors.right.height}";
          }
        ];
        exec = [
          "exec swaymsg workspace 10, move workspace to \"eDP-1\""
          "exec swaymsg workspace 1, move workspace to \"'${monitors.left.criteria}'\""
          "exec swaymsg workspace 2, move workspace to \"'${monitors.right.criteria}'\""
        ];
      };
    };
in
{
  services = {
    kanshi = {
      enable = enableWayland;
      settings =
        [
          {
            profile.name = "undocked";
            profile.outputs = [
              {
                criteria = "eDP-1";
                status = "enable";
                mode = "1920x1080";
              }
            ];
          }
          (createDualDockedIdenticalProfile {
            left_criteria = "AOC 2460G5 F54GABA004914";
            right_criteria = "Samsung Electric Company C27HG7x HTHJ700995";
            width = 1920;
            height = 1080;
          })
          (createDualDockedIdenticalProfile {
            left_criteria = "AOC 2460G5 0x00001332";
            right_criteria = "Samsung Electric Company C27HG7x HTHJ700995";
            width = 1920;
            height = 1080;
          })
          (createDualDockedIdenticalProfile {
            left_criteria = "Dell Inc. DELL U2719D 74RRT13";
            right_criteria = "Dell Inc. DELL U2717D J0XYN99BA3TS";
            width = 2560;
            height = 1440;
          })
          (createDualDockedIdenticalProfile {
            left_criteria = "Dell Inc. DELL U2717D J0XYN989CU9S";
            right_criteria = "Dell Inc. DELL U2719D 7RRBC23";
            width = 2560;
            height = 1440;
          })
          {
            profile.name = "home";
            profile.outputs = [
              {
                criteria = "eDP-1";
                status = "enable";
                mode = "1920x1080";
                position = "1920,520";
              }
              {
                criteria = "AOC 2460G5 0x00001332";
                status = "enable";
                mode = "1920x1080";
                position = "0,0";
              }
            ];
          }

        ]
        ++ (builtins.map createLeftDockedProfile [
          "Iiyama North America PL3288UH 1169612412790"
          "Iiyama North America PL3288UH 1169612412785"
          "Dell Inc. DELL SE3223Q DH6SKK3"
          "Dell Inc. DELL SE3223Q 7S1SKK3"
          "Dell Inc. DELL SE3223Q CS1SKK3"
          "Dell Inc. DELL SE3223Q D02SKK3"
          "Dell Inc. DELL SE3223Q 7V1SKK3"
        ]);
    };
  };
}
