{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  programs = {
    autorandr = {
      enable = true;
    };

    bat = {
      enable = true;
      config = {
        theme = "gruvbox-dark";
      };
      themes = {
        gruvbox = {
          src = inputs.gruvbox-tmTheme;
          file = "gruvbox (Dark) (Soft).tmTheme";
        };
      };
    };

    broot = {
      enable = true;
      settings = {
        modal = true;
        verbs = [
          {
            invocation = "edit";
            shortcut = "e";
            key = "enter";
            execution = "$EDITOR {file}";
            leave_broot = false;
            apply_to = "file";
          }
          {
            invocation = "view";
            shortcut = "v";
            execution = "bat {file}";
          }
          {
            invocation = "parent";
            shortcut = "p";
            execution = ":parent";
          }
        ];
        default_flags = "gh";
        quit_on_last_cancel = true;
        imports = [
          {
            file = "dark-gruvbox.hjson";
            luma = [
              "dark"
              "unknown"
            ];
          }
        ];
      };
    };

    eza = {
      enable = true;
      enableFishIntegration = true;
    };

    gh = {
      enable = true;
      settings = {
        editor = "vim";
        git_protocol = "ssh";
        pager = "less";
        browser = "brave";
      };
      gitCredentialHelper = {
        enable = true;
      };
      extensions = [
        pkgs.gh-dash
        pkgs.gh-eco
      ];
    };

    autojump = {
      enable = true;
    };

    fzf = {
      enable = true;
    };
  };
}
