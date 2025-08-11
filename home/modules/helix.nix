{
  config,
  lib,
  pkgs,
  inputs,
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
    // previousSubword
    // nextSubword
    // gotoWord
    // previousWord
    // nextWord;
  # Move to the first non-whitespace character in the line
  startOfLineContents = makeKeymap "home" [
    "goto_line_start"
    "goto_first_nonwhitespace"
  ];
  gotoWord = makeKeymap "ret" "goto_word";
  previousSubword = makeKeymap "A-home" [ "move_prev_sub_word_end" ];
  nextSubword = makeKeymap "A-end" [ "move_next_sub_word_end" ];
  previousWord = makeKeymap "C-h" [ "move_prev_sub_word_end" ];
  nextWord = makeKeymap "C-l" [ "move_next_sub_word_end" ];
  # Previous/next buffer
  previousBuffer = makeKeymap "H" "goto_previous_buffer";
  nextBuffer = makeKeymap "L" "goto_next_buffer";

  smartTabMacros = smartTabMoveStart // smartTabMoveEnd;
  smartTabMoveEnd = makeKeymap "tab" "move_parent_node_end";
  smartTabMoveStart = makeKeymap "S-tab" "move_parent_node_start";

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
    // selectAllOccurance
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
  # Select All Occurances of Selection
  selectAllOccurance = makeKeymap "C-A" "@*%s<ret>";
  # Select current word, and otherwise jump to next instance of word
  selectCurrentWord = makeKeymap "'" "@miw*v";
  selectNextCurrentWord = makeKeymap "'" "@n,";

  windowMacros = {
    "space" = {
      "o" = "file_picker_in_current_buffer_directory";
      "q" = ":buffer-close";
      "Q" = ":write-buffer-close";
      "P" = "no_op";
      "p" = {
        "g" = makeBufferWith "gitui";
      };
      "B" = ":echo %sh{git blame -L %{cursor_line},+1 %{buffer_name}}";
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
  programs = {
    helix = {
      enable = true;
      defaultEditor = true;
      package = pkgs.helix;
      settings = {
        theme = "gruvbox_dark_soft";
        editor = {
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          cursorline = true;
          indent-guides = {
            render = true;
            character = "|";
            skip-levels = 1;
          };
          idle-timeout = 200;
          completion-timeout = 5;
          completion-trigger-len = 2;
          color-modes = true;
          line-number = "relative";
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
          bufferline = "always";
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
          insert = { };
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
        language-server = {
          harper = {
            command = "${pkgs.harper}/bin/harper-ls";
            args = [ "--stdio" ];
            config = {
              harper-ls = {
                userDictPath = ../../.config/harper.dictionary;
                linters = {
                  SentenceCapitalization = false;
                  BoringWords = true;
                };
              };
            };
          };
          marksman = {
            command = "${pkgs.marksman}/bin/marksman";
          };
          simple-completion-language-server = {
            command = "${pkgs.simple-completion-language-server}/bin/simple-completion-language-server";
            environment = {
              SNIPPETS_PATH = ./helix/snippets;
            };
          };
        };
        language =
          let
            mkLspUsage =
              lsps:
              [
                "simple-completion-language-server"
                "harper"
              ]
              ++ lsps;
          in
          [
            {
              name = "git-commit";
              file-types = [ { glob = "COMMIT_EDITMSG"; } ];
              soft-wrap = {
                enable = true;
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
              ];
            }
          ];
      };
    };
  };
}
