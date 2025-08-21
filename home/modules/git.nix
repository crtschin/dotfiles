{
  config,
  pkgs,
  inputs,
  ...
}:
let
  lib = pkgs.lib;
  precondition =
    assert lib.asserts.assertMsg (builtins.hasAttr "git" pkgs.configuration) ''
      Should configure git using an overlay
      git = {
        userEmail = "<userEmail>";
        userName = "<userName>";
        signingKey = "<signingKey>";
      };
    '';
    {
      userName = pkgs.configuration.git.userName;
      userEmail = pkgs.configuration.git.userEmail;
      signingKey = pkgs.configuration.git.signingKey;
    };
  gpgSign =
    sigingKey:
    {
      gpg.format = "ssh";
    }
    // lib.optionalAttrs (sigingKey != null) {
      user.signingkey = sigingKey;
      commit.gpgsign = false;
    };

in
{
  programs = {
    gitui = {
      enable = true;
      theme = ''
        (  
          selection_bg: Some("${pkgs.riceExtendedColorPalette.selection_background}"),
          selection_fg: Some("${pkgs.riceExtendedColorPalette.selection_foreground}"),
          command_fg: Some("${pkgs.riceExtendedColorPalette.background}"),
          cmdbar_bg: Some("${pkgs.riceExtendedColorPalette.foreground}"),
          cmdbar_extra_lines_bg: Some("${pkgs.riceExtendedColorPalette.foreground}"),
        )
        '';
      keyConfig = ''
        (
          open_help: Some(( code: Char('?'), modifiers: "")),

          move_left: Some(( code: Char('h'), modifiers: "")),
          move_right: Some(( code: Char('l'), modifiers: "")),
          move_up: Some(( code: Char('k'), modifiers: "")),
          move_down: Some(( code: Char('j'), modifiers: "")),

          popup_up: Some(( code: Char('p'), modifiers: "CONTROL")),
          popup_down: Some(( code: Char('n'), modifiers: "CONTROL")),

          shift_up: Some(( code: Char('K'), modifiers: "SHIFT")),
          shift_down: Some(( code: Char('J'), modifiers: "SHIFT")),

          edit_file: Some(( code: Char('I'), modifiers: "SHIFT")),
          status_reset_item: Some(( code: Char('U'), modifiers: "SHIFT")),

          diff_reset_lines: Some(( code: Char('u'), modifiers: "")),
          diff_stage_lines: Some(( code: Char('s'), modifiers: "")),

          stashing_save: Some(( code: Char('w'), modifiers: "")),
          stashing_toggle_index: Some(( code: Char('m'), modifiers: "")),

          stash_open: Some(( code: Char('l'), modifiers: "")),
          abort_merge: Some(( code: Char('M'), modifiers: "SHIFT")),
        )
        '';
    };

    jujutsu = {
      enable = true;
      settings = {
        user = {
          name = precondition.userName;
          email = precondition.userEmail;
        };
      };
    };

    git = with precondition; {
      inherit userName userEmail;
      enable = true;
      lfs.enable = true;
      delta.enable = true;
      # Prevent bad objects from spreading.
      # transfer.fsckObjects = true;
      extraConfig = {
        alias = {
          lc = "!fish -c 'git checkout (git branch --list --sort=-committerdate | string trim | fzf --preview=\"git log --stat -n 10 --decorate --color=always {}\")'";
          oc = "!fish -c 'git checkout (git for-each-ref refs/remotes/origin/ --format=\"%(refname:short)\" --sort=-committerdate|perl -p -e \"s#^origin/##g\"|head -100|string trim|fzf --preview=\"git log --stat -n 10 --decorate --color=always origin/{}\")'";
        };
        # blame.ignoreRevsFile = ".git-blame-ignore-revs";
        pager = {
          diff = "delta";
          log = "delta";
          reflog = "delta";
          show = "delta";
        };
        core = {
          editor = "${pkgs.vim}/bin/vim";
          excludesfile = "${../../.config/global.gitignore}";
        };
        merge = {
          conflictstyle = "diff3";
          difftool = "${pkgs.meld}/bin/meld";
        };
        delta = {
          features = "interactive unobtrusive-line-numbers decorations";
          syntax-theme = "gruvbox-dark";
        };
        diff = {
          external = "difft";
          algorithm = "histogram";
          # Try to break up diffs at blank lines
          compactionHeuristic = true;
          colorMoved = "dimmed_zebra";
        };
        # For interactive rebases, automatically reorder and set the
        # right actions for !fixup and !squash commits.
        rebase = {
          autosquash = true;
          updateRefs = true;
        };
        # Include tags with commits that we push
        push = {
          followTags = true;
          autoSetupRemote = true;
        };
        # Sort tags in version order, e.g. `v1 v2 .. v9 v10` instead
        # of `v1 v10 .. v9`
        tag.sort = "version:refname";
        # Remeber conflict resolutions. If the same conflict appears
        # again, use the previous resolution.
        rerere.enabled = true;
      } // gpgSign signingKey;
    };
  };
}
