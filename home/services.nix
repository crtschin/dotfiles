{ pkgs, ... }:
{
  services.home-manager.autoExpire = {
    enable = true;
    store = {
      cleanup = true;
    };
  };
  # systemd.user.services.update-lock-screens = {
  #   Unit = {
  #     Description = "Update lock screens";
  #   };

  #   Install = {
  #     WantedBy = [ "timers.target" ];
  #   };

  #   Timer = {
  #     OnBootSec = "1min";
  #   };

  #   Service = {
  #     ExecStart = "${pkgs.betterlockscreen}/bin/betterlockscreen -u %h/Pictures/Wallpapers";
  #   };
  # };

  # systemd.user.services.pgadmin4 = {
  #   Unit = {
  #     Description = "Runs pgAdmin4";
  #   };

  #   Install = {
  #     WantedBy = ["timers.target"];
  #   };

  #   Timer = {
  #     OnBootSec = "5min";
  #   };

  #   Service = {
  #     ExecStart = "${pkgs.pgadmin}/bin/pgadmin4";
  #   };
  # };
}
