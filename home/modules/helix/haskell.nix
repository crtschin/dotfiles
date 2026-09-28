# Haskell configuration.
{
  pkgs,
  inputs,
  mkLspUsage,
  system,
}:
let
  inherit (pkgs) lib;
  enableTreehouse = pkgs.configuration.ghcCoreTools;
  haskellContrib = inputs.tree-sitter-haskell-contrib.packages.${system};
  # Link a grammar package's parser and its Helix queries into Helix's runtime.
  # `lang` names the Helix language, giving both the runtime dir and <lang>.so.
  # The grammars ship their query files under queries/helix/.
  mkGrammar =
    lang: pkg: queries:
    {
      "helix/runtime/grammars/${lang}.so".source = "${pkg}/parser";
    }
    // builtins.listToAttrs (
      map (q: {
        name = "helix/runtime/queries/${lang}/${q}.scm";
        value.source = "${pkg}/queries/helix/${q}.scm";
      }) queries
    );
  haskellHighlights = pkgs.runCommand "haskell-highlights.scm" { } ''
    cat ${pkgs.helix.HELIX_DEFAULT_RUNTIME}/queries/haskell/highlights.scm > $out
    printf '\n[\n  "signature"\n] @keyword.import\n' >> $out
  '';

  # GHC Core dump extensions, shared by the ghc_core language and treehouse's
  # extension to language map below.
  ghcCoreFileTypes = [
    "dump-simpl"
    "dump-ds"
    "dump-ds-preopt"
    "dump-prep"
    "dump-spec"
    "dump-spec-constr"
    "dump-cse"
    "dump-float-out"
    "dump-float-in"
    "dump-worker-wrapper"
    "dump-call-arity"
    "dump-exitify"
    "dump-liberate-case"
    "dump-occur-anal"
    "dump-late-cc"
    "dump-static-argument-transformation"
    "dump-simpl-iterations"
  ];

  # treehouse is a generic tree-sitter LSP. It gives symbols and go-to-definition
  # for GHC Core dumps by running the ghc_core grammar's tags query. Taking no
  # arguments, it reads this XDG config to map the Core dump extensions to the
  # grammar's parser and to the Helix query directory holding tags.scm.
  ghcCoreGrammar = haskellContrib.tree-sitter-ghc-core;
  treehousePkg = inputs.treehouse.packages.${system}.default;
  treehouseConfig = pkgs.writeText "treehouse-config.json" (
    builtins.toJSON {
      languages.ghc_core = {
        grammar = "${ghcCoreGrammar}/parser";
        symbol = "ghc_core";
        queries = "${ghcCoreGrammar}/queries/helix";
      };
      extensions = builtins.listToAttrs (
        map (ft: {
          name = ".${ft}";
          value = "ghc_core";
        }) ghcCoreFileTypes
      );
      # Core dumps live under dist-newstyle, which projects gitignore. Whitelisting
      # it over the gitignore prune lets treehouse scan sibling dumps, so cross-file
      # go-to-definition resolves. Markers root the scan at the project, putting the
      # whole tree in scope.
      workspace = {
        markers = [
          "cabal.project"
          ".git"
        ];
        whitelist = [ "dist-newstyle" ];
      };
    }
  );
in
{
  # Grammar parsers + Helix queries linked into the runtime.
  configFile =
    mkGrammar "cabal" haskellContrib.tree-sitter-cabal [
      "highlights"
      "tags"
      "textobjects"
      "indents"
      "locals"
      "rainbows"
    ]
    // mkGrammar "cabal_project" haskellContrib.tree-sitter-cabal-project [
      "highlights"
      "tags"
      "textobjects"
      "indents"
    ]
    # GHC intermediate-language dumps: Core/STG/Cmm members + the dump container.
    // mkGrammar "ghc_core" haskellContrib.tree-sitter-ghc-core [
      "highlights"
      "tags"
      "textobjects"
      "indents"
      "locals"
      "rainbows"
    ]
    // mkGrammar "ghc_stg" haskellContrib.tree-sitter-ghc-stg [
      "highlights"
      "tags"
      "textobjects"
      "indents"
      "locals"
      "rainbows"
    ]
    // mkGrammar "ghc_cmm" haskellContrib.tree-sitter-ghc-cmm [
      "highlights"
      "tags"
      "textobjects"
      "indents"
      "locals"
      "rainbows"
    ]
    // mkGrammar "ghc_dump" haskellContrib.tree-sitter-ghc-dump [
      "highlights"
      "injections"
    ]
    // {
      "helix/runtime/queries/haskell/highlights.scm".source = haskellHighlights;
    }
    // lib.optionalAttrs enableTreehouse {
      "treehouse/config.json".source = treehouseConfig;
    };

  languageServers = {
    haskell-language-server = {
      # Not the wrapper: it resolves `haskell-language-server-<ghc-version>` off
      # PATH before the plain binary next to it, so a stale nixpkgs HLS anywhere
      # later in PATH hijacks the project's own build.
      command = "haskell-language-server";
      args = [ "--lsp" ];
      config = {
        sessionLoading = "multipleComponents";
        plugin = {
          export = {
            globalOn = true;
          };
          rename = {
            config = {
              crossModule = true;
            };
          };
        };
      };
    };
  }
  // lib.optionalAttrs enableTreehouse {
    treehouse = {
      command = "${treehousePkg}/bin/treehouse";
    };
  };

  # Only haskell is listed here. The contrib grammars above come prebuilt from
  # the flake, and their .so lands in the runtime as a read-only store symlink,
  # so `hx --grammar build` cannot write it. Listing them would make every
  # `hx --grammar build` fail.
  grammars = [
    {
      name = "haskell";
      "source" = {
        git = "https://github.com/crtschin/tree-sitter-haskell";
        rev = inputs.tree-sitter-haskell.rev;
      };
    }
  ];

  languages = [
    {
      name = "cabal";
      file-types = [ "cabal" ];
      rulers = [ 80 ];
      language-servers = mkLspUsage [
        "haskell-language-server"
      ];
    }
    {
      name = "cabal_project";
      scope = "source.cabal_project";
      file-types = [
        { "glob" = "cabal.project"; }
        { "glob" = "cabal.project.local"; }
      ];
      comment-tokens = "--";
      indent = {
        tab-width = 2;
        unit = "  ";
      };
      rulers = [ 80 ];
      language-servers = mkLspUsage [ "haskell-language-server" ];
    }
    (
      {
        name = "ghc_core";
        scope = "source.ghc_core";
        file-types = ghcCoreFileTypes;
        comment-tokens = "--";
        indent = {
          tab-width = 2;
          unit = "  ";
        };
      }
      // lib.optionalAttrs enableTreehouse {
        # treehouse provides symbols and go-to-definition for Core bindings. This
        # skips mkLspUsage because spellcheck and completion on generated Core is
        # noise.
        language-servers = [ "treehouse" ];
      }
    )
    {
      name = "ghc_stg";
      scope = "source.ghc_stg";
      file-types = [
        "dump-stg-final"
        "dump-stg-from-core"
        "dump-stg-cg"
        "dump-stg-tags"
        "dump-stg-unarised"
      ];
      comment-tokens = "--";
      indent = {
        tab-width = 2;
        unit = "  ";
      };
    }
    {
      name = "ghc_cmm";
      scope = "source.ghc_cmm";
      file-types = [
        "dump-cmm"
        "dump-cmm-from-stg"
        "dump-cmm-raw"
        "dump-opt-cmm"
        "dump-cmm-cbe"
        "dump-cmm-cfg"
        "dump-cmm-cps"
        "dump-cmm-info"
        "dump-cmm-proc"
        "dump-cmm-sink"
        "dump-cmm-sp"
        "dump-cmm-switch"
        "dump-cmm-verbose"
      ];
      comment-tokens = "//";
      indent = {
        tab-width = 4;
        unit = "    ";
      };
    }
    {
      name = "ghc_dump";
      scope = "source.ghc_dump";
      file-types = [ "dump" ];
      indent = {
        tab-width = 2;
        unit = "  ";
      };
    }
    {
      name = "haskell";
      scope = "source.haskell";
      injection-regex = "hs|haskell";
      file-types = [
        "hs"
        "hs-boot"
        "hsc"
        # Backpack module signatures. Cabal treats these as ordinary Haskell
        # source (builtinHaskellSuffixes), and the forked grammar parses them.
        "hsig"
      ];
      roots = [
        "Setup.hs"
        "stack.yaml"
        "cabal.project"
        "hie.yaml"
      ];
      shebangs = [
        "runhaskell"
        "stack"
      ];
      comment-token = "--";
      block-comment-tokens = {
        start = "{-";
        end = "-}";
      };
      language-servers = mkLspUsage [ "haskell-language-server" ];
      indent = {
        tab-width = 2;
        unit = "  ";
      };
      # Haskell-Debugger (hdb) DAP adapter.
      # Requires GHC >= 9.14.1 and `hdb` on PATH. Install with:
      #   cabal install haskell-debugger \
      #     --allow-newer=base,time,containers,ghc,ghc-bignum,template-haskell \
      #     --enable-executable-dynamic
      # hdb runs as a DAP server over TCP. Helix spawns `hdb server --port <port>`
      # then connects to 127.0.0.1:<port>. Start a session with `:debug-start`.
      debugger = {
        name = "haskell-debugger";
        transport = "tcp";
        command = "hdb";
        args = [ "server" ];
        port-arg = "--port {}";
        templates = [
          {
            # Helix has no ${file} or ${workspaceFolder} variables, so these get
            # prompted. entryPoint and projectRoot have defaults, so press enter.
            name = "main";
            request = "launch";
            completion = [
              {
                name = "entryFile";
                completion = "filename";
              }
              {
                name = "entryPoint";
                default = "main";
              }
              {
                name = "projectRoot";
                completion = "directory";
                default = ".";
              }
            ];
            args = {
              entryFile = "{0}";
              entryPoint = "{1}";
              projectRoot = "{2}";
              entryArgs = [ ];
              extraGhcArgs = [ ];
            };
          }
        ];
      };
    }
  ];
}
