{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./common.nix
  ];

  home = rec {
    username = "crtschin";
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      git
      htop
      arandr
      curl
      feh
      file
      wget
      gcc
      python
      rustc
      rustfmt
      cargo

      texlive.combined.scheme-full
      vlc
      filezilla
    ];
  };

  gtk = {
    enable = true;
    font = {
      package = pkgs.rice.font.monospace.package;
      name = pkgs.rice.font.monospace.name;
      size = 12;
    };
    theme = {
      name = "gruvbox-dark";
      package = pkgs.gruvbox-dark-gtk;
    };
    iconTheme = {
      name = "gruvbox-dark";
      package = pkgs.gruvbox-dark-icons-gtk;
    };
  };

  services = {
    random-background = {
      enable = true;
      imageDirectory = "%h/backgrounds";
    };
  };

  programs = {
    git = {
      userName = "crtschin";
      userEmail = "csochinjensem@gmail.com";
    };

    fish = {
      shellInit = ''
        begin
          set fish_greeting
          set __done_notify_sound 1
        end

        function __direnv_export_eval --on-event fish_prompt
            begin
                begin
                    ${pkgs.direnv}/bin/direnv export fish
                end 1>| source
            end 2>| egrep -v -e "^direnv: export"
        end

        set (gnome-keyring-daemon --start | string split "=")
      '';
    };
  };
}
