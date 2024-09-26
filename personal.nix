{ config
, pkgs
, inputs
, ...
}: {
  imports = [
    ./common.nix
    ./home/modules/alacritty.nix
    ./home/modules/general-overlay.nix
  ];

  nixpkgs.overlays = [ inputs.tidal.overlays.default ];
  home = rec {
    username = "crtschin";
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      pciutils
      iotop
      pv
      valgrind
      discord
      glxinfo

      pavucontrol jack2 qjackctl jack2Full jack_capture
      supercollider superdirt-start tidal

      devenv
      process-compose
      git
      htop
      arandr
      curl
      feh
      file
      wget
      gcc
      python3
      rustc
      rustfmt
      cargo

      vlc
      filezilla
    ];
  };

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      vim-cool
      vim-airline
      vim-tidal
      (nvim-treesitter.withPlugins (p: [p.haskell]))
      vim-surround
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
    picom = {
      enable = false;
    };
  };

  programs = {
    git = {
      userName = "crtschin";
      userEmail = "csochinjensem@gmail.com";
      gpg.format = "ssh";
      user.signingkey = "/home/crtschin/.ssh/id_rsa.pub"
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
