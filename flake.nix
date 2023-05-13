{
  inputs = {
    nixpkgs = {
      # url = "flake:nixpkgs/nixpkgs-unstable";
      url = "flake:nixpkgs/nixos-22.11";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-direnv = {
      url = "github:nix-community/nix-direnv/2.2.1";
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

    fish-pisces = {
      url = "github:laughedelic/pisces";
      flake = false;
    };
    fish-plugin-git = {
      url = "github:jhillyerd/plugin-git";
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

      # Lifted from https://github.com/yoricksijsling/dotfiles
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
