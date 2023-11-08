{
  inputs = {
    channableFishFile = {
      url = "file+file:///home/curtis/dotfiles/.config/channable.fish";
      flake = false;
    };

    nixpkgs = {
      url = "flake:nixpkgs/nixos-unstable";
      # url = "flake:nixpkgs/nixos-23.11";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-direnv = {
      url = "github:nix-community/nix-direnv/2.3.0";
      inputs.flake-utils.follows = "flake-utils";
    };

    nixgl = {
      url = "github:guibou/nixGL";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-rice = {
      url = "github:bertof/nix-rice";
    };

    gruvbox-tmTheme = {
      url = "github:subnut/gruvbox-tmTheme";
      flake = false;
    };

    fish-plugin-git = {
      url = "github:jhillyerd/plugin-git";
      flake = false;
    };
    fish-puffer = {
      url = "github:nickeb96/puffer-fish";
      flake = false;
    };
    fish-abbreviation-tips = {
      url = "github:gazorby/fish-abbreviation-tips";
      flake = false;
    };
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-rice,
    nixgl,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    overlays = [nix-rice.overlays.default nixgl.overlay];
    pkgs =
      nixpkgs.legacyPackages.${system}
      // {
        inherit overlays;
        config = {allowUnfree = true;};
      };

    # Lifted from https://github.com/yoricksijsling/dotfiles
    makeHomeConfiguration = {extraModules ? []}:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          # Pass all inputs to every module. It's a bit excessive, but allows us to easily refer
          # to stuff like inputs.nixgl.
          inherit inputs;
          # The dotfiles argument always points to the flake root.
          dotfiles = self;
        };
        modules = [] ++ extraModules;
      };
  in {
    inherit makeHomeConfiguration;

    homeConfigurations = {
      work = makeHomeConfiguration {extraModules = [./work.nix];};
      personal = makeHomeConfiguration {extraModules = [./personal.nix];};
    };

    nixosConfigurations = {
      personal = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
    };
  };
}
