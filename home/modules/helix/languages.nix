# Helix language support: grammars, language servers, and per-language config.
# Owns `mkLspUsage` and imports the Haskell-specific module, returning:
#   - configFile: grammar parser/query runtime links for xdg.configFile
#   - languages:  the programs.helix.languages value
{ pkgs, inputs }:
let
  # Every language gets completion + spellcheck on top of its own servers.
  mkLspUsage =
    lsps:
    [
      "simple-completion-language-server"
      "codebook-lsp"
    ]
    ++ lsps;
  haskell = import ./haskell.nix { inherit pkgs inputs mkLspUsage; };
in
{
  configFile = haskell.configFile;
  languages = {
    use-grammars = {
      except = [ ];
    };
    language-server = {
      codebook-lsp = {
        command = "${pkgs.codebook}/bin/codebook-lsp";
        args = [ "serve" ];
      };
      marksman = {
        command = "${pkgs.marksman}/bin/marksman";
      };
      docker-language-server = {
        command = "${pkgs.docker-language-server}/bin/docker-language-server";
        args = [
          "start"
          "--stdio"
        ];
        config = {
          docker-language-server = {
            telemetry = "off";
          };
        };
      };
      simple-completion-language-server = {
        command = "${pkgs.simple-completion-language-server}/bin/simple-completion-language-server";
        environment = {
          SNIPPETS_PATH = ./snippets;
        };
      };
      mdpls = {
        command = "mdpls";
        config = {
          markdown.preview.auto = false;
          markdown.preview.browser = "firefox";
        };
      };
      steel-language-server = {
        command = "steel-language-server";
      };
      basedpyright = {
        command = "basedpyright-langserver";
        args = [ "--stdio" ];
        except-features = [
          "format"
          "code-action"
        ];
        config = {
          basedpyright.analysis = {
            autoSearchPaths = true;
            diagnosticMode = "openFilesOnly";
          };
        };
      };
      ruff = {
        command = "ruff";
        args = [
          "server"
          "--preview"
        ];
      };
    }
    // haskell.languageServers;
    grammar = [
      {
        "name" = "nix";
        "source" = {
          git = "https://github.com/nix-community/tree-sitter-nix";
          rev = inputs.tree-sitter-nix.rev;
        };
      }
      {
        "name" = "gitcommit";
        "source" = {
          git = "https://github.com/gbprod/tree-sitter-gitcommit";
          rev = inputs.tree-sitter-gitcommit.rev;
        };
      }
    ]
    ++ haskell.grammars;
    language = [
      {
        name = "git-commit";
        file-types = [ { glob = "COMMIT_EDITMSG"; } ];
        soft-wrap = {
          enable = false;
          max-wrap = 4;
          max-indent-retain = 16;
          wrap-at-text-width = true;
        };
        text-width = 72;
        rulers = [
          50
          72
        ];
        language-servers = mkLspUsage [
          "marksman"
        ];
      }
      {
        name = "nix";
        language-servers = mkLspUsage [ "nixd" ];
      }
      {
        name = "python";
        language-servers = mkLspUsage [
          "basedpyright"
          "ruff"
        ];
      }
      {
        name = "dockerfile";
        language-servers = mkLspUsage [ "docker-language-server" ];
      }
      {
        name = "docker-compose";
        language-servers = mkLspUsage [ "docker-language-server" ];
      }
      {
        name = "scheme";
        language-servers = mkLspUsage [ "steel-language-server" ];
        formatter = {
          command = "${pkgs.parinfer-rust}/bin/parinfer-rust";
          args = [
            "--mode"
            "paren"
            "-l"
            "scheme"
          ];
        };
        auto-format = true;
      }
      {
        name = "markdown";
        file-types = [ "md" ];
        soft-wrap = {
          enable = true;
          max-wrap = 4;
          max-indent-retain = 16;
          wrap-at-text-width = true;
        };
        text-width = 80;
        rulers = [ 80 ];
        language-servers = mkLspUsage [
          "marksman"
          "mdpls"
        ];
      }
    ]
    ++ haskell.languages;
  };
}
