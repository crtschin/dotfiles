{
  inputs = {
    nixpkgs = {
      # url = "github:NixOS/nixpkgs?ref=7b9135d3ae24bf15ca0fac57f4114c99e28bec3b";
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      # url = "flake:nixpkgs/nixos-26.11";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # UTIL

    nix-std = {
      url = "github:chessai/nix-std";
    };

    nixgl = {
      url = "github:guibou/nixGL";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tuicr = {
      url = "github:agavra/tuicr";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    # RICE

    nix-rice = {
      url = "github:bertof/nix-rice?ref=dddd03ed3c5e05c728b0df985f7af905b002f588";
      inputs.nixpkgs-lib.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pre-commit-hooks.follows = "git-hooks";
    };

    gruvbox-tmTheme = {
      url = "github:subnut/gruvbox-tmTheme";
      flake = false;
    };

    wofi-themes = {
      url = "github:joao-vitor-sr/wofi-themes-collection/540e247819fbf8116d73e4fd2e4b481a25d81353";
      flake = false;
    };

    # EDITOR

    tree-sitter-haskell-contrib = {
      # url = "path:/home/crtschin/personal/tree-sitter-haskell-contrib";
      # url = "github:crtschin/tree-sitter-haskell-contrib/crtschin/next";
      url = "github:crtschin/tree-sitter-haskell-contrib";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    tree-sitter-nix = {
      url = "github:nix-community/tree-sitter-nix";
      flake = false;
    };

    tree-sitter-gitcommit = {
      url = "github:gbprod/tree-sitter-gitcommit";
      flake = false;
    };

    treehouse = {
      url = "path:/home/crtschin/personal/treehouse";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix-crtschin = {
      url = "github:crtschin/helix?ref=crts/scratch-with-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "helix/rust-overlay";
    };

    steel = {
      url = "github:mattwparas/steel";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    awesome-neovim-plugins = {
      url = "github:m15a/flake-awesome-neovim-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-doom-emacs-unstraightened = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "";
    };

    # SHELL

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

    # PRIVATE
    private = {
      url = "path:/home/crtschin/personal/privatefiles";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.git-hooks.follows = "git-hooks";
    };
  };
  outputs =
    {
      self,
      flake-utils,
      git-hooks,
      nixpkgs,
      home-manager,
      nix-rice,
      nixgl,
      helix-crtschin,
      awesome-neovim-plugins,
      nix-std,
      private,
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

      pythonEnv = pkgs.python3.withPackages (ps: [ ps.click ]);

      # The hook's pyright must resolve third-party imports (click in
      # cabal-dep-paths.py), so wrap it with pythonEnv on PATH. pass_filenames
      # = false (below) types the whole pyrightconfig.json scope.
      pyright-typecheck = pkgs.writeShellApplication {
        name = "pyright-typecheck";
        runtimeInputs = [
          pkgs.pyright
          pythonEnv
        ];
        text = "pyright";
      };

      # Formatting / lint / type hooks: installed into .git/hooks on
      # `nix develop` and enforced by `nix flake check`. The .sh scripts are
      # already shellcheck'd by writeShellApplication at build time; there are
      # no Python tests yet, so neither is gated here.
      pre-commit-check = git-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixfmt-rfc-style = {
            enable = true;
            # pkgs.nixfmt-rfc-style is a deprecated alias; use the canonical attr.
            package = pkgs.nixfmt;
          };
          ruff.enable = true;
          ruff-format.enable = true;
          pyright-typecheck = {
            enable = true;
            name = "pyright";
            entry = "${pyright-typecheck}/bin/pyright-typecheck";
            language = "system";
            files = "^home/modules/scripts/.*\\.py$";
            pass_filenames = false;
          };
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
          modules = [
            private.homeModule
            inputs.nix-doom-emacs-unstraightened.homeModule
          ]
          ++ extraModules;
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
        # `nix flake check` runs the formatting / lint / type hooks over the tree.
        checks.pre-commit-check = pre-commit-check;

        devShells.default = mkShell {
          # Entering the shell installs this repo's git pre-commit hook.
          inherit (pre-commit-check) shellHook;
          buildInputs = [
            nixfmt
            shellcheck
            ruff
            basedpyright
            pythonEnv
          ]
          ++ pre-commit-check.enabledPackages;
        };
      }
    );
}
