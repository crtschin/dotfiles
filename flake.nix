{
  inputs = {
    nixpkgs = {
      # url = "github:NixOS/nixpkgs?ref=7b9135d3ae24bf15ca0fac57f4114c99e28bec3b";
      url = "github:NixOS/nixpkgs/nixos-unstable";
      # url = "flake:nixpkgs/nixos-23.11";
    };

    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix-crtschin = {
      url = "github:crtschin/helix?ref=crts/scratch-with-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-std = {
      url = "github:chessai/nix-std";
    };

    nixgl = {
      url = "github:guibou/nixGL";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-rice = {
      url = "github:bertof/nix-rice?ref=dddd03ed3c5e05c728b0df985f7af905b002f588";
    };
    tidal = {
      url = "github:mitchmindtree/tidalcycles.nix";
    };
    musnix = {
      url = "github:musnix/musnix";
    };

    gruvbox-tmTheme = {
      url = "github:subnut/gruvbox-tmTheme";
      flake = false;
    };

    wofi-themes = {
      url = "github:joao-vitor-sr/wofi-themes-collection/540e247819fbf8116d73e4fd2e4b481a25d81353";
      flake = false;
    };

    Pipshag_dotfiles_gruvbox = {
      url = "github:Pipshag/dotfiles_gruvbox/5a9ffe19953bde48bb42a4164fb43eb915de0aeb";
      flake = false;
    };

    awesome-neovim-plugins.url = "github:m15a/flake-awesome-neovim-plugins";

    fish-puffer = {
      url = "github:nickeb96/puffer-fish";
      flake = false;
    };
    fish-abbreviation-tips = {
      url = "github:gazorby/fish-abbreviation-tips";
      flake = false;
    };
    fish-async-prompt = {
      url = "github:acomagu/fish-async-prompt";
      flake = false;
    };
    nix-doom-emacs-unstraightened = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "";
    };
  };
  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
      home-manager,
      nix-rice,
      nixgl,
      helix-crtschin,
      awesome-neovim-plugins,
      nix-std,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      std = nix-std;
      overlays = [
        nix-rice.overlays.default
        nixgl.overlay
        helix-crtschin.overlays.default
        awesome-neovim-plugins.overlays.default
      ];
      pkgs = nixpkgs.legacyPackages.${system} // {
        inherit overlays;
        config = {
          allowUnfree = true;
        };
      };

      # Lifted from https://github.com/yoricksijsling/dotfiles
      makeHomeConfiguration =
        {
          extraModules ? [ ],
          email ? "csochinjensem@gmail.com",
        }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            # Pass all inputs to every module. It's a bit excessive, but allows us to easily refer
            # to stuff like inputs.nixgl.
            inherit inputs;
            inherit email;
            inherit std;
            # The dotfiles argument always points to the flake root.
            dotfiles = self;
          };
          modules = extraModules ++ [ inputs.nix-doom-emacs-unstraightened.homeModule ];
        };
    in
    {
      homeConfigurations = {
        work = makeHomeConfiguration {
          extraModules = [ ./work.nix ];
          email = "curtis.chinjensem@scrive.com";
        };
        impromptu = makeHomeConfiguration { extraModules = [ ./work.nix ]; };
        personal = makeHomeConfiguration { extraModules = [ ./personal.nix ]; };
      };

      nixosConfigurations = {
        personal = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
          ];
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system: with pkgs; {
        devShells.default = mkShell {
          buildInputs = [ nixfmt-rfc-style ];
        };
      }
    );
}
