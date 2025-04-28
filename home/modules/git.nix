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
