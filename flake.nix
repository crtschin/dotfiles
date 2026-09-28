{
  inputs = {
    nixpkgs = {
      # url = "github:NixOS/nixpkgs?ref=7b9135d3ae24bf15ca0fac57f4114c99e28bec3b";
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      # url = "flake:nixpkgs/nixos-26.11";
    };

    # Unmerged nixpkgs pull requests, pinned to the pull request head commit so
    # a force push cannot change what builds. packagesFromNixpkgs below lifts
    # single packages out of them. Drop the input once the change reaches
    # nixpkgs-unstable.
    #
    # NixOS/nixpkgs#565929: claude-code 2.1.280
    nixpkgs-pr-565929 = {
      url = "github:NixOS/nixpkgs/6af5cd1a6acc0416bd2c85197480dafe374eeb53";
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

    tree-sitter-haskell = {
      url = "github:crtschin/tree-sitter-haskell/crtschin/scratch";
      flake = false;
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
      url = "git+ssh://git@github.com/crtschin/treehouse";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.coreviewer.follows = "coreviewer";
    };

    coreviewer = {
      url = "git+ssh://git@github.com/crtschin/coreviewer";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.git-hooks.follows = "git-hooks";
      inputs.hs-bindgen.inputs.nixpkgs.follows = "nixpkgs";
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
      # Take the named packages from another nixpkgs checkout. The config has to
      # match the one below, or an unfree package throws on evaluation.
      packagesFromNixpkgs =
        input: names:
        let
          other = import input {
            inherit system;
            config = {
              allowUnfree = true;
            };
          };
        in
        _: _: nixpkgs.lib.getAttrs names other;

      overlays = [
        nix-rice.overlays.default
        nixgl.overlay
        helix-crtschin.overlays.default
        awesome-neovim-plugins.overlays.default
        (packagesFromNixpkgs inputs.nixpkgs-pr-565929 [ "claude-code" ])
      ];
      pkgs = import nixpkgs {
        inherit system overlays;
        config = {
          allowUnfree = true;
        };
      };

      pythonEnv = pkgs.python3.withPackages (ps: [ ps.click ]);

      # Ships forge, the cog installer `just install-plugins` drives.
      steelPkg = inputs.steel.packages.${system}.steel;

      # The hook's pyright must resolve third-party imports, so wrap it with
      # pythonEnv on PATH. pass_filenames = false types the whole
      # pyrightconfig.json scope.
      pyright-typecheck = pkgs.writeShellApplication {
        name = "pyright-typecheck";
        runtimeInputs = [
          pkgs.pyright
          pythonEnv
        ];
        text = "pyright";
      };

      # Formatting, lint and type hooks. `nix develop` installs them into
      # .git/hooks and `nix flake check` enforces them. Neither shell nor Python
      # tests are gated here. writeShellApplication already shellchecks the .sh
      # scripts at build time, and there are no Python tests yet.
      pre-commit-check = git-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixfmt-rfc-style = {
            enable = true;
            # pkgs.nixfmt-rfc-style is a deprecated alias for this attr.
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
            # Excessive, but it lets any module refer to inputs.nixgl and friends
            # without threading them through.
            inherit inputs;
            inherit email;
            inherit std;
            # The one build system, resolved here so modules index
            # inputs.<x>.packages.${system} without re-deriving it from pkgs.
            inherit system;
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
      # Local Helix Steel cogs to forge-install
      helixSteelPlugins = private.steelPlugins;

      homeConfigurations = {
        work = makeHomeConfiguration {
          extraModules = [ ./work.nix ];
          email = "curtis.chinjensem@scrive.com";
        };
        impromptu = makeHomeConfiguration {
          extraModules = [ ./work.nix ];
          email = "github@crtschin.nl";
        };
        personal = makeHomeConfiguration {
          extraModules = [ ./personal.nix ];
          email = "github@crtschin.nl";
        };
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
    // flake-utils.lib.eachSystem [ system ] (
      _: with pkgs; {
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
            steelPkg
          ]
          ++ pre-commit-check.enabledPackages;
        };
      }
    );
}
