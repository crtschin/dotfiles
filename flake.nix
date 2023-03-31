{
  inputs = {
    channableFishFile = {
      url = "file+file:///home/curtis/dotfiles/.config/channable.fish";
      flake = false;
    };

    nixpkgs = {
      url = "flake:nixpkgs/nixpkgs-unstable";
      # url = "flake:nixpkgs/nixos-22.11";
      # url = "flake:nixpkgs/c3912035d00ef755ab19394488b41feab95d2e40";
    };

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      # url = "github:nix-community/home-manager/release-22.11";
      inputs.utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-direnv = {
      url = "github:nix-community/nix-direnv/2.2.1";
    };

    nixgl = {
      url = "github:guibou/nixGL";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-rice = {
      url = "github:bertof/nix-rice";
    };

    fish-pisces = {
      url = "github:laughedelic/pisces";
      flake = false;
    };
    fish-git-abbr = {
      url = "github:lewisacidic/fish-git-abbr";
      flake = false;
    };
    fish-z = {
      url = "github:jethrokuan/z";
      flake = false;
    };
    fish-bass = {
      url = "github:edc/bass";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, home-manager, nix-rice, nixgl, ... }@inputs:
    let
      system = "x86_64-linux";
      overlays = [ nix-rice.overlays.default nixgl.overlay ];
      pkgs = nixpkgs.legacyPackages.${system} // {
        inherit overlays;
        config = { allowUnfree = true; };
      };

      # I don't want to include work stuff in this repo, so we expose a function that constructs
      # the home manager configuration if you pass it a list of additional modules that you want
      # to include.
      # The homeManagerConfiguration call must be done inside this flake, because it refers to
      # files within the repo (for example mc-lists.el).
      makeHomeConfiguration = {extraModules ? []}: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          # Pass all inputs to every module. It's a bit excessive, but allows us to easily refer
          # to stuff like inputs.nixgl.
          inherit inputs;
          # The dotfiles argument always points to the flake root.
          dotfiles = self;
        };
        modules = [ ] ++ extraModules;
      };
    in
    {
      inherit makeHomeConfiguration;

      homeConfigurations = {
        work = makeHomeConfiguration { extraModules = [ ./work.nix ]; };
        personal = makeHomeConfiguration { extraModules = [ ./personal.nix ]; };
      };

      nixosConfigurations = {
        hostname = nixpkgs.lib.nixosSystem {
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
