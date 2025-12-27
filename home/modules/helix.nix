{
  config,
  lib,
  pkgs,
  inputs,
  std,
  ...
}:
let
  makeKeymap = key: keymap: { ${key} = keymap; };
  makeBufferWith = cmd: [
    ":write-all"
    ":new"
    ":insert-output ${cmd} >/dev/tty"
    ":set mouse false"
    ":set mouse true"
    ":buffer-close!"
    ":redraw"
    ":reload-all"
  ];

  noArrowKeys = {
    "up" = "no_op";
    "down" = "no_op";
    "left" = "no_op";
    "right" = "no_op";
  };

  # Movement
  movementMacros =
    startOfLineContents
    // smartTabMacros
    // previousBuffer
    // nextBuffer
    // gotoWord
    // pageUp
    // pageDown
    // insertMacros;
  # Move to the first non-whitespace character in the line
  startOfLineContents = makeKeymap "home" [
    "goto_line_start"
    "goto_first_nonwhitespace"
  ];
  gotoWord = makeKeymap "ret" "goto_word";
  # Previous/next buffer
  previousBuffer = makeKeymap "H" "goto_previous_buffer";
  nextBuffer = makeKeymap "L" "goto_next_buffer";
  pageUp = makeKeymap "pageup" "page_up";
  pageDown = makeKeymap "pagedown" "page_down";
  smartTabMacros = smartTabMoveStart // smartTabMoveEnd;
  smartTabMoveEnd = makeKeymap "tab" "move_parent_node_end";
  smartTabMoveStart = makeKeymap "S-tab" "move_parent_node_start";

  insertMacros = { } // previousWord // nextWord // previousSubword // nextSubword;
  previousWord = makeKeymap "A-home" [ "move_prev_word_end" ];
  nextWord = makeKeymap "A-end" [ "move_next_word_start" ];
  previousSubword = makeKeymap "C-home" [ "move_prev_sub_word_end" ];
  nextSubword = makeKeymap "C-end" [ "move_next_sub_word_start" ];

  # Changes
  # Move/copy line below/above
  changeMacros = moveLineDown // moveLineUp // copyLineDown // copyLineUp;
  moveLineDown = makeKeymap "A-j" [
    "extend_to_line_bounds"
    "delete_selection"
    "paste_after"
  ];
  moveLineUp = makeKeymap "A-k" [
    "extend_to_line_bounds"
    "delete_selection"
    "move_line_up"
    "paste_before"
  ];
  copyLineDown = makeKeymap "A-J" [
    "extend_to_line_bounds"
    "yank"
    "paste_after"
  ];
  copyLineUp = makeKeymap "A-K" [
    "extend_to_line_bounds"
    "yank"
    "paste_before"
  ];

  # Selection
  selectionMacros =
    clearSelection
    // selectAll
    // selectAllAlias
    // selectAllOccurrence
    // selectLineAbove
    // selectLineBelow
    // selectionBuffer
    // selectionBufferBoundaries;
  # Clear any selections
  clearSelection = makeKeymap "esc" [
    "keep_primary_selection"
    "collapse_selection"
    "normal_mode"
  ];
  selectLineBelow = makeKeymap "x" "select_line_below";
  selectLineAbove = makeKeymap "X" "select_line_above";
  # Select All
  selectAll = makeKeymap "%" [
    "save_selection"
    "select_all"
  ];
  selectAllAlias = makeKeymap "C-a" "@<%>";
  selectionBuffer = makeKeymap "*" "search_selection";
  selectionBufferBoundaries = makeKeymap "A-*" "search_selection_detect_word_boundaries";
  # Select All Occurrences of Selection
  selectAllOccurrence = makeKeymap "C-A" "@*%s<ret>";
  # Select current word, and otherwise jump to next instance of word
  selectCurrentWord = makeKeymap "'" "@miw*v";
  selectNextCurrentWord = makeKeymap "'" "@n,";

  windowMacros = {
    "=" = ":reflow";
    "space" = {
      "o" = "file_picker_in_current_buffer_directory";
      "q" = ":buffer-close";
      "Q" = ":write-buffer-close";
      "P" = "no_op";
      "C" = "no_op";
      "C-c" = "toggle_block_comments";
      "c" = {
        # Turn something into a record selector combinatory
        "s" = "@bems(bi.<esc>";
        # Turn a field selection to use dot selection
        "f" = "@be*d<A-d>ea.<esc>p";
      };
      "p" = {
        "t" = makeBufferWith "gitui";
        "g" = makeBufferWith "lazygit";
        "d" = makeBufferWith "lazydocker";
        "s" = makeBufferWith "lazysql";
        "y" = makeBufferWith "yazi";
      };
      "g" = {
        "g" = "changed_file_picker";
        "b" =
          ":echo %sh{git show --no-patch --format='%%h (%%an: %%ar): %%s' $(git blame -p %{buffer_name} -L%{cursor_line},+1 | head -1 | cut -d' ' -f1)}";
        "B" = ":sh gh browse %{buffer_name}:%{selection_line_start}-%{selection_line_end}";
        "C-b" = ":sh ${pkgs.gitBlameURL} %{buffer_name} %{cursor_line}";
        "s" = ":git-inline.stage-lines";
        "c" = makeBufferWith "git commit";
        # "s" = [
        #   ":write"
        #   ":sh git add --"
        #   ":redraw"
        # ];
      };
      "space" = [
        ":format"
        ":write"
      ];
      "C-space" = [
        "format_selections"
        ":write"
      ];
    };
    "C-p" = "file_picker";
    "C-P" = "command_palette";
  };
  normalMode = makeKeymap "v" "normal_mode";

  # Make sure there is only one selection, select word under cursor, set search to selection, then switch to select mode
  initializeSelection = makeKeymap "C-d" "@,miw*v";
  # If already in select mode, just add new selection at next occurrence
  expandSelection = makeKeymap "C-d" [
    "search_selection"
    "extend_search_next"
  ];

  selectModeMacros = normalMode // expandSelection // selectNextCurrentWord;
  normalModeMacros = initializeSelection // selectCurrentWord;
in
{
  xdg.configFile = {
    # "helix/init.scm".source = ../../.config/helix/init.scm;
    # "helix/helix.scm".source = ../../.config/helix/helix.scm;
    "helix/runtime/queries/cabal/highlights.scm".source = ../../.config/helix/cabal/highlights.scm;
    "codebook/codebook.toml".source = ../../.config/codebook.toml;
  };
  programs = {
    helix = {
      enable = true;
      defaultEditor = true;
      package = pkgs.helix.overrideAttrs (oa: {
        cargoBuildFeatures = (oa.cargoBuildFeatures or [ ]) ++ [ "steel" ];
      });
      settings = {
        theme = "gruvbox_dark_soft";
        editor = {
          bufferline = "always";
          color-modes = true;
          completion-replace = true;
          completion-timeout = 5;
          completion-trigger-len = 2;
          cursorline = true;
          cursorcolumn = true;
          idle-timeout = 200;
          jump-label-alphabet = "jklfdsahgzuiorewqytm,.vcxnb";
          line-number = "relative";
          popup-border = "all";
          rainbow-brackets = true;
          scrolloff = 4;
          trim-final-newlines = true;
          trim-trailing-whitespace = true;
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          file-picker = {
            hidden = false;
          };
          indent-guides = {
            render = true;
            character = "|";
            skip-levels = 1;
          };
          lsp = {
            auto-signature-help = true;
            display-idle-hover-docs = true;
            display-color-swatches = true;
            display-inlay-hints = true;
            display-messages = true;
            display-progress-messages = true;
            display-signature-help-docs = true;
          };
          statusline = {
            left = [
              "mode"
              "spinner"
              "diagnostics"
            ];
            center = [ "file-name" ];
            right = [
              "selections"
              "position"
              "file-encoding"
              "file-type"
            ];
          };
          soft-wrap = {
            enable = false;
            wrap-at-text-width = false;
          };
          auto-save = {
            focus-lost = true;
            after-delay.enable = true;
          };
          gutters = { };
          rulers = [
            80
            100
          ];
        };
        keys = {
          insert = {
            "C-." = "completion";
          }
          // insertMacros;
          normal =
            noArrowKeys
            // windowMacros
            // changeMacros
            // movementMacros
            // selectionMacros
            // normalModeMacros;
          select = noArrowKeys // movementMacros // selectionMacros // selectModeMacros;
        };
      };
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
              SNIPPETS_PATH = ./helix/snippets;
            };
          };
          mdpls = {
            command = "mdpls";
            config = {
              markdown.preview.auto = false;
              markdown.preview.browser = "firefox";
            };
          };
          haskell-language-server = {
            command = "haskell-language-server-wrapper";
            config = {
              sessionLoading = "multipleComponents";
              rename = {
                config = "crossModule";
              };
              formattingProvider = "fourmolu";
            };
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
        };
        grammar = [
          {
            "name" = "cabal";
            "source" = {
              git = "https://github.com/crtschin/tree-sitter-cabal";
              rev = "2fc3b701d6ca17467a9ab35719403e0893e4e971";
            };
          }
        ];
        language =
          let
            mkLspUsage =
              lsps:
              [
                "simple-completion-language-server"
                "codebook-lsp"
              ]
              ++ lsps;
          in
          [
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
              name = "cabal";
              file-types = [ "cabal" ];
              rulers = [ 80 ];
              language-servers = mkLspUsage [
                "haskell-language-server"
              ];
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
            }
            {
              name = "markdown";
              file-types = [ "md" ];
              soft-wrap = {
                enable = false;
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
          ];
      };
    };
  };
}
