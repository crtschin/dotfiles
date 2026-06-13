{
  config,
  lib,
  pkgs,
  inputs,
  std,
  ...
}:
let
  keymap = import ./helix/keymap.nix { inherit pkgs; };
  langs = import ./helix/languages.nix { inherit pkgs inputs; };
in
{
  xdg.configFile = {
    "helix/init.scm".source = ./helix/init.scm;
    "helix/helix.scm".source = ./helix/helix.scm;
    "codebook/codebook.toml".source = ../../.config/codebook.toml;
  }
  // langs.configFile;
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
          completion-replace = false;
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
        keys = keymap;
      };
      languages = langs.languages;
    };
  };
}
