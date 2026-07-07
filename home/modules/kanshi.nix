{ pkgs, ... }:
let
  inherit (pkgs)
    createDockedProfile
    createDualDockedProfile
    createDualDockedIdenticalProfile
    createKanshiProfile
    kanshiLaptopOutput
    ;

  # Single external monitor docked to the right of the laptop (Channable desks).
  channableDockedProfile =
    monitor:
    createDockedProfile {
      inherit monitor;
      width = 2560;
      height = 1440;
      side = "right";
    };

  # Catch-all for any unrecognised external, such as a projector or meeting-room TV.
  # kanshi returns the first profile whose outputs match, so this only fires once
  # every serial-specific profile has been ruled out. The exec puts workspace 2 on
  # the external so slides land there.
  presentationFallbackProfile = {
    profile = {
      name = "presentation_fallback";
      outputs = [
        (createKanshiProfile (
          kanshiLaptopOutput
          // {
            x = 0;
            y = 0;
          }
        ))
        (createKanshiProfile {
          criteria = "*";
          x = kanshiLaptopOutput.width;
          y = 0;
        })
      ];
      exec = [ "${pkgs.lib.getExe pkgs.moveWorkspaceToExternalOutput} 2" ];
    };
  };

  # Every profile that names concrete monitors. Kept separate from the settings list
  # so a new desk group has nowhere to land after the catch-all.
  deskProfiles = [
    {
      profile.name = "undocked";
      profile.outputs = [
        (createKanshiProfile (
          kanshiLaptopOutput
          // {
            x = 0;
            y = 0;
          }
        ))
      ];
    }
    (createDualDockedProfile {
      left = {
        criteria = "AOC 2460G5 F54GABA004914";
        width = 1920;
        height = 1080;
      };
      right = {
        criteria = "Samsung Electric Company C27HG7x HTHJ700995";
        width = 2560;
        height = 1440;
      };
      laptop = {
        enable = false;
        x = 0;
        y = 0;
      };
    })
    (createDualDockedIdenticalProfile {
      left = "Dell Inc. DELL U2719D 74RRT13";
      right = "Dell Inc. DELL U2717D J0XYN99BA3TS";
      width = 2560;
      height = 1440;
    })
    (createDualDockedIdenticalProfile {
      left = "Dell Inc. DELL U2717D J0XYN989CU9S";
      right = "Dell Inc. DELL U2719D 7RRBC23";
      width = 2560;
      height = 1440;
    })
    (createDualDockedIdenticalProfile {
      left = "Dell Inc. DELL U2719D D8F5SS2";
      right = "Dell Inc. DELL U2719D F2KFV13";
      width = 2560;
      height = 1440;
    })
    (createDualDockedIdenticalProfile {
      left = "HP Inc. HP E243 CNK0430BR5";
      right = "HP Inc. HP E243d CNC1211CS2";
      width = 1920;
      height = 1080;
    })
    (createDualDockedIdenticalProfile {
      left = "HP Inc. HP E273 CNK0162V79";
      right = "HP Inc. HP E273 CNK0162V7J";
      width = 1920;
      height = 1080;
      laptop = {
        enable = false;
        x = 1920;
        y = 1080;
      };
    })
    (createDockedProfile {
      monitor = "AOC 2460G5 0x00001332";
      width = 1920;
      height = 1080;
      side = "left";
    })
    (createDockedProfile {
      monitor = "HP Inc. HP E243 CNK0430BR5";
      width = 1920;
      height = 1080;
      side = "up";
    })
  ]
  ++ map channableDockedProfile [
    "Iiyama North America PL3288UH 1169612412790"
    "Iiyama North America PL3288UH 1169612412785"
    "Iiyama North America PL3288UH 1169612412871"
    "Iiyama North America PL3288UH 1169612412877"
    "Iiyama North America PL3288UH 1169612410134"
    "Dell Inc. DELL SE3223Q DH6SKK3"
    "Dell Inc. DELL SE3223Q 7S1SKK3"
    "Dell Inc. DELL SE3223Q CS1SKK3"
    "Dell Inc. DELL SE3223Q D02SKK3"
    "Dell Inc. DELL SE3223Q 7V1SKK3"
    "Dell Inc. DELL SE3223Q D3XRKK3"
    "Dell Inc. DELL SE3223Q DDCSKK3"
    "Dell Inc. DELL SE3223Q DR1SKK3"
    "Dell Inc. DELL SE3223Q 7J6SKK3"
  ];
in
{
  services.kanshi = {
    enable = pkgs.configuration.flags.protocol.wayland;
    settings = deskProfiles ++ [ presentationFallbackProfile ];
  };
}
