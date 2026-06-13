# Helix keymaps: macro definitions and the insert/normal/select bindings.
# Returns the `keys` value that helix.nix drops into editor settings.
{ pkgs }:
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
    "+" = "format_selections";
    "space" = {
      "o" = "file_picker_in_current_buffer_directory";
      "q" = ":buffer-close";
      "Q" = ":buffer-close!";
      "P" = "no_op";
      "e" = "file_explorer";
      "E" = "file_explorer_in_current_buffer_directory";
      "C" = "no_op";
      "l" = "show_code_lenses_under_cursor";
      "k" = "goto_hover";
      "K" = [
        ":yank-diagnostic"
        ":new"
        ":clipboard-paste-before"
      ];
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
        # "s" = ":git-inline.stage-lines";
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
}
