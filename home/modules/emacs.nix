{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  init = {
    name = "init.el";
    path = pkgs.writeText "init.el" ''
      ;;; init.el -*- lexical-binding: t; -*-
      (doom! :input
             english
             ;;japanese
             ;;layout

             :completion
             company
             vertico

             :ui
             doom
             doom-dashboard
             doom-quit
             hl-todo
             indent-guides
             modeline
             ophints
             (popup +defaults)
             vc-gutter
             vi-tilde-fringe
             workspaces

             :editor
             (evil +everywhere)
             (format +onsave)
             file-templates
             fold
             snippets

             :emacs
             dired
             electric
             undo
             vc

             :checkers
             syntax

             :tools
             (eval +overlay)
             lookup
             lsp
             magit

             :os
             (:if IS-MAC macos)

             :lang
             emacs-lisp
             (haskell +lsp)
             markdown
             nix
             org
             python
             sh
             yaml
             docker

             :config
             (default +bindings +smartparens))
    '';
  };
  config = {
    name = "config.el";
    path = pkgs.writeText "config.el" ''
      ;;; config.el -*- lexical-binding: t; -*-

      (setq doom-theme 'doom-gruvbox)
      (setq display-line-numbers-type 'relative)
      (setq doom-modeline-buffer-file-name-style 'relative-to-project)

      ;; Indent guides
      (setq display-fill-column-indicator-column 80)
      (global-display-fill-column-indicator-mode)

      ;; Disable arrow keys
      (map! :n "<up>" #'ignore
            :n "<down>" #'ignore
            :n "<left>" #'ignore
            :n "<right>" #'ignore)

      ;; Helix-like keybindings
      (map! :n "C-p" #'projectile-find-file
            :n "C-S-p" #'execute-extended-command
            :n "H" #'previous-buffer
            :n "L" #'next-buffer
            :n "x" #'evil-visual-line)

      ;; Drag lines
      (map! :n "M-j" #'drag-stuff-down
            :n "M-k" #'drag-stuff-up)
      (after! drag-stuff
        (drag-stuff-global-mode 1))

      ;; Helix space menu approximations
      (map! :leader
            "SPC" (cmd! (format-all-buffer) (save-buffer))
            "o" #'find-file
            "q" #'kill-current-buffer)
    '';
  };
  packages = {
    name = "packages.el";
    path = pkgs.writeText "packages.el" ''
      ;;; packages.el -*- lexical-binding: t; -*-
      (package! drag-stuff)
      (package! doom-themes)
    '';
  };
  doom-config = pkgs.linkFarm "doom-config" [
    init
    config
    packages
  ];
in
{
  programs = {
    doom-emacs = {
      enable = false;
      doomDir = doom-config;
    };
  };
  services = {
    emacs = {
      enable = false;
    };
  };
}
