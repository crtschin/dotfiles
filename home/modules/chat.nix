{
  config,
  lib,
  pkgs,
  ...
}:
let
  configuration = pkgs.configuration;
  sway = configuration.flags.sway;

  # TUI chat clients. Each opens in its own kitty window whose --class sets the
  # Wayland app_id, so the assign rule routes only that window. Binary name is
  # assumed to match the client name.
  workspace = 2;
  clients = [
    {
      name = "senpai";
      package = pkgs.senpai;
    }
    # { name = "gomuks"; package = pkgs.gomuks; }
  ];

  launch = c: "${pkgs.kitty}/bin/kitty --class ${c.name} ${c.package}/bin/${c.name}";
in
{
  home.packages = map (c: c.package) clients;

  # All chat clients open in kitty on the chat workspace (${toString workspace}).
  wayland.windowManager.sway = lib.mkIf sway {
    config.startup = map (c: { command = launch c; }) clients;
    extraConfig = lib.concatMapStrings (c: ''
      assign [app_id="${c.name}"] ${toString workspace}
    '') clients;
  };
}
