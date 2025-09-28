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
      enableFishIntegration = true;
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
            invocation = "preview";
            shortcut = "v";
            key = "enter";
            internal = "open_preview";
          }
        ];
        default_flags = "h";
        quit_on_last_cancel = true;
        preview_transformers = [
          {
            input_extensions = [ "pdf" ];
            output_extension = "png";
            mode = "image";
            command = [
              "${pkgs.mupdf}/bin/mutool"
              "draw"
              "-w"
              "1000"
              "-o"
              "{output-path}"
              "{input-path}"
            ];
          }
          {
            input_extensions = [ "json" ];
            output_extension = "json";
            mode = "text";
            command = [
              "${pkgs.jq}/bin/jq"
              "-C"
            ];
          }
          {
            input_extensions = [ "md" ];
            output_extension = "md";
            mode = "text";
            command = [
              "${pkgs.glow}/bin/glow"
            ];
          }
        ];
        enable_kitty_keyboard = true;
        imports = [
          {
            file = "skins/dark-gruvbox.hjson";
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
