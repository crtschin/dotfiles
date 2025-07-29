{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  makeKeymap = key: keymap: { ${key} = keymap; };
  noArrowKeys = {
    "up" = "no_op";
    "down" = "no_op";
    "left" = "no_op";
    "right" = "no_op";
  };

  # Movement
  movementMacros =
    startOfLineContents // previousBuffer // nextBuffer // previousSubword // nextSubword // gotoWord;
  # Move to the first non-whitespace character in the line
  startOfLineContents = makeKeymap "home" [
    "goto_line_start"
    "goto_first_nonwhitespace"
  ];
  gotoWord = makeKeymap "ret" "goto_word";
  previousSubword = makeKeymap "A-home" [ "move_prev_sub_word_end" ];
  nextSubword = makeKeymap "A-end" [ "move_next_sub_word_end" ];
  # Previous/next buffer
  previousBuffer = makeKeymap "H" "goto_previous_buffer";
  nextBuffer = makeKeymap "L" "goto_next_buffer";

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
  selectionMacros = clearSelection // selectAll // selectAllOccurance // nextOccurence // currentWord;
  # Clear any selections
  clearSelection = makeKeymap "esc" [
    "keep_primary_selection"
    "collapse_selection"
  ];
  # Select All
  selectAll = makeKeymap "C-a" "@<%>";
  # Select All Occurances of Selection
  selectAllOccurance = makeKeymap "C-A" "@*%s<ret>";
  # Select current word
  currentWord = makeKeymap "A-w" "@miw";
  nextOccurence = makeKeymap "C-'" [
    "search_selection"
    "search_next"
  ];

  windowMacros = {
    "space" = {
      "o" = "file_picker_in_current_buffer_directory";
      "q" = ":write-buffer-close";
    };
  };

  # Make sure there is only one selection, select word under cursor, set search to selection, then switch to select mode
  initializeSelection = makeKeymap "C-d" [
    "keep_primary_selection"
    "move_next_word_end"
    "move_prev_word_start"
    "search_selection"
    "select_mode"
  ];
  # If already in select mode, just add new selection at next occurrence
  expandSelection = makeKeymap "C-d" [
    "search_selection"
    "extend_search_next"
  ];
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
          line-number = "relative";
          lsp = {
            auto-signature-help = true;
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
          };
          gutters = { };
          rulers = [
            80
            100
          ];
        };
        keys = {
          insert = { };
          normal = noArrowKeys // windowMacros // changeMacros // movementMacros // selectionMacros // initializeSelection;
          select = noArrowKeys // movementMacros // selectionMacros // expandSelection;
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
        };
        language = [
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
            language-servers = [
              "harper"
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
            language-servers = [
              "harper"
              "marksman"
            ];
          }
        ];
      };
    };
  };
}
