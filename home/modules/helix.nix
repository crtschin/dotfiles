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
  clearSelection = makeKeymap "esc" [
    "collapse_selection"
    "keep_primary_selection"
  ];
  nextOccurence = makeKeymap "C-'" [
    "search_selection"
    "search_next"
  ];
  # If already in select mode, just add new selection at next occurrence
  expandSelection = makeKeymap "C-d" [
    "search_selection"
    "extend_search_next"
  ];
  # make sure there is only one selection, select word under cursor, set search to selection, then switch to select mode
  initializeSelection = makeKeymap "C-d" [
    "keep_primary_selection"
    "move_next_word_end"
    "move_prev_word_start"
    "search_selection"
    "select_mode"
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
          line-number = "relative";
          lsp.display-messages = true;
          bufferline = "always";
          soft-wrap = {
            enable = true;
            wrap-at-text-width = true;
          };
        };
        keys = {
          insert = { } // initializeSelection;
          normal = noArrowKeys // initializeSelection // clearSelection // nextOccurence;
          select = noArrowKeys // expandSelection // clearSelection // nextOccurence;
        };
        editor = {
          auto-save = {
            focus-lost = true;
          };
          rulers = [
            80
            100
          ];
        };
      };
      languages = {
        language-server.ltex-ls-plus = {
          command = "${pkgs.ltex-ls-plus}/bin/ltex-ls-plus";
        };
        language = [
          {
            name = "git-commit";
            language-servers = [ "ltex-ls-plus" ];
          }
        ];
      };
    };
  };
}
