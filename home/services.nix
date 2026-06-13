{ pkgs, ... }:
{
  services = {
    lorri = {
      enable = true;
      enableNotifications = true;
    };
    home-manager = {
      autoUpgrade = {
        enable = false;
        flakeDir = "/home/crtschin/personal/dotfiles";
        frequency = "weekly";
        useFlake = true;
        preSwitchCommands = [ "nix flake update" ];
      };
      autoExpire = {
        enable = true;
        store = {
          cleanup = true;
        };
      };
    };
  };
}
