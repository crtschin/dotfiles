{
  config,
  pkgs,
  inputs,
  ...
}:
let
  overlay = self: super: {
    useWayland = true;
    configuration = {
      git = {
        userEmail = "csochinjensem@gmail.com";
        userName = "crtschin";
        signingKey = "/home/crtschin/.ssh/id_rsa.pub";
      };
      wm = "sway";
    };
  };

  overlays = [
    overlay
    inputs.tidal.overlays.default
    (import ./home/overlays/entry.nix)
    (import ./home/overlays/rice.nix)
    (import ./home/overlays/wm.nix)
  ];
in
{
  imports = [
    ./common.nix
  ];

  nixpkgs.overlays = overlays;

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
      unzip

      pavucontrol
      jdk23
      # jack2
      # qjackctl jack2Full jack_capture
      # supercollider superdirt-start tidal

      docker
      docker-compose
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
      (nvim-treesitter.withPlugins (p: [ p.haskell ]))
      vim-surround
    ];
  };

  services = {
    random-background = {
      # enable = true;
      imageDirectory = "%h/backgrounds";
    };
    ssh-agent.enable = true;
    gnome-keyring.enable = true;
  };

  programs = {
    fish = {
      shellInit = ''
        begin
          set fish_greeting
          set __done_notify_sound 1
        end

        function __direnv_export_eval --on-event fish_prompt
            begin
                begin
                    ${pkgs.direnv}/bin/direnv export ${pkgs.fish}/bin/fish
                end 1>| source
            end 2>| egrep -v -e "^direnv: export"
        end

        set (gnome-keyring-daemon --start | string split "=")
      '';
    };
  };
}
