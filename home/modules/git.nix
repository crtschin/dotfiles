{
  config,
  pkgs,
  inputs,
  system,
  ...
}:
let
  lib = pkgs.lib;
  deltaBin = lib.getExe pkgs.delta;
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
in
{
  home.packages = [
    # Not programs.delta. That module only adds this package while git
    # integration is off, and setting any `options` there wraps delta in
    # `--config <store file>`, which it loads instead of gitconfig. The [delta]
    # section below and per-repo overrides such as diffsbs would go silent.
    pkgs.delta
    inputs.tuicr.packages.${system}.default
  ];

  # tuicr: https://github.com/agavra/tuicr/blob/main/docs/CONFIG.md
  xdg.configFile."tuicr/config.toml".text = ''
    theme = "gruvbox-dark"
    # Kept at the default. Space would shadow the built-in toggle-expand and
    # commit-picker selection bindings, which tuicr does not let us remap.
    leader = ";"

    [forge]
    comment_type_prefix = false
  '';

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
        author = {
          name = precondition.userName;
          email = precondition.userEmail;
        };
      };
    };

    git = {
      enable = true;
      lfs.enable = true;
      # Prevent bad objects from spreading.
      # transfer.fsckObjects = true;
      # attributes = [
      #   "* merge=mergiraf"
      # ];
      # Also emits gpg.ssh.program, the ssh-keygen signer path.
      signing = {
        format = "ssh";
        key = precondition.signingKey;
        signByDefault = false;
      };
      settings = {
        user = {
          name = precondition.userName;
          email = precondition.userEmail;
          useConfigOnly = true;
        };
        author = {
          name = precondition.userName;
          email = precondition.userEmail;
        };
        alias = {
          lc = "!fish -c 'git checkout (git branch --list --sort=-committerdate | string trim | fzf --preview=\"git log --stat -n 10 --decorate --color=always {}\")'";
          oc = "!fish -c 'git checkout (git for-each-ref refs/remotes/origin/ --format=\"%(refname:short)\" --sort=-committerdate|perl -p -e \"s#^origin/##g\"|head -100|string trim|fzf --preview=\"git log --stat -n 10 --decorate --color=always origin/{}\")'";
        };
        # blame.ignoreRevsFile = ".git-blame-ignore-revs";
        # Absolute, so an earlier `delta` on PATH cannot take over the pager.
        pager = {
          log = deltaBin;
          # diff = "difft";
          reflog = deltaBin;
          show = deltaBin;
        };
        # The pager settings above do not reach interactive staging, so `git add
        # -p` would render raw diffs.
        interactive.diffFilter = "${deltaBin} --color-only";
        delta = {
          features = "interactive unobtrusive-line-numbers decorations";
          syntax-theme = "gruvbox-dark";
        };
        core = {
          # core.editor outranks EDITOR, so name the editor explicitly. Uses the
          # configured package, since `pkgs.helix` lacks the Steel build.
          editor = lib.getExe' config.programs.helix.package "hx";
          excludesfile = "${../../.config/global.gitignore}";
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
        # Remember conflict resolutions. If the same conflict appears
        # again, reuse the previous resolution.
        rerere.enabled = true;
      };
    };
  };
}
