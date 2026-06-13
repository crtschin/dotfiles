# Haskell/GHC Helix configuration: tree-sitter grammars for Cabal and GHC
# intermediate-language dumps, haskell-language-server, and the language
# definitions. Returns fragments that helix.nix splices into its own config so
# there is a single definition site per Helix option.
#
# `mkLspUsage` is passed in from helix.nix so the base language-server list
# (completion + spellcheck) stays defined once.
{
  pkgs,
  inputs,
  mkLspUsage,
}:
let
  cabalPkgs = inputs.tree-sitter-haskell-contrib.packages.${pkgs.system};
  # Link a grammar package's parser and its Helix queries into Helix's
  # runtime. `lang` is the Helix language (its runtime dir + <lang>.so); the
  # grammars ship their query files under queries/helix/.
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
  # Grammar source entries all live in the same tree-sitter-haskell-contrib flake input.
  mkGrammarSource = name: subdir: {
    inherit name;
    "source" = {
      git = "https://github.com/crtschin/tree-sitter-haskell-contrib";
      rev = inputs.tree-sitter-haskell-contrib.rev;
      inherit subdir;
    };
  };
in
{
  # Grammar parsers + Helix queries linked into the runtime.
  configFile =
    mkGrammar "cabal" cabalPkgs.tree-sitter-cabal [
      "highlights"
      "tags"
      "textobjects"
      "indents"
    ]
    // mkGrammar "cabal_project" cabalPkgs.tree-sitter-cabal-project [
      "highlights"
      "tags"
      "textobjects"
      "indents"
    ]
    # GHC intermediate-language dumps: Core/STG/Cmm members + the dump container.
    // mkGrammar "ghc_core" cabalPkgs.tree-sitter-ghc-core [
      "highlights"
      "tags"
      "textobjects"
      "indents"
    ]
    // mkGrammar "ghc_stg" cabalPkgs.tree-sitter-ghc-stg [
      "highlights"
      "tags"
      "textobjects"
      "indents"
    ]
    // mkGrammar "ghc_cmm" cabalPkgs.tree-sitter-ghc-cmm [
      "highlights"
      "tags"
      "textobjects"
      "indents"
    ]
    // mkGrammar "ghc_dump" cabalPkgs.tree-sitter-ghc-dump [
      "highlights"
      "injections"
    ];

  languageServers = {
    haskell-language-server = {
      command = "haskell-language-server-wrapper";
      config = {
        sessionLoading = "multipleComponents";
        rename = {
          config = "crossModule";
        };
      };
    };
  };

  grammars = [
    (mkGrammarSource "cabal" "tree-sitter-cabal")
    (mkGrammarSource "cabal_project" "tree-sitter-cabal-project")
    (mkGrammarSource "ghc_core" "tree-sitter-ghc-core")
    (mkGrammarSource "ghc_stg" "tree-sitter-ghc-stg")
    (mkGrammarSource "ghc_cmm" "tree-sitter-ghc-cmm")
    (mkGrammarSource "ghc_dump" "tree-sitter-ghc-dump")
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
    {
      name = "ghc_core";
      scope = "source.ghc_core";
      file-types = [
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
      comment-tokens = "--";
      indent = {
        tab-width = 2;
        unit = "  ";
      };
    }
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
      # Requires GHC >= 9.14.1 and `hdb` on PATH; install with:
      #   cabal install haskell-debugger \
      #     --allow-newer=base,time,containers,ghc,ghc-bignum,template-haskell \
      #     --enable-executable-dynamic
      # hdb runs as a DAP server over TCP: Helix spawns `hdb server --port <port>`
      # then connects to 127.0.0.1:<port>. Start a session with `:debug-start`.
      debugger = {
        name = "haskell-debugger";
        transport = "tcp";
        command = "hdb";
        args = [ "server" ];
        port-arg = "--port {}";
        templates = [
          {
            # Helix has no ${file}/${workspaceFolder} variables, so these are
            # prompted; entryPoint and projectRoot have defaults (just press enter).
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
