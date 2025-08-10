{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  wayland = {
    windowManager = {
      hyprland = {
        enable = false;
        # xwayland.enable = true;
      };
    };
  };
}
