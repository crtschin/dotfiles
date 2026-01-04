{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
in
{
  programs.opencode = {
    enable = true;
    settings = {
      theme = "gruvbox";
      compaction = {
        auto = true;
        prune = true;
      };
      keybinds = {
        leader = "ctrl+shift+p";
      };
    };
    skills = {
      steel-helix-buffer = ./opencode/skills-helix-steel-buffer.md;
      steel-helix-plugin = ./opencode/skills-helix-steel-plugin.md;
      steel-helix-ui = ./opencode/skills-helix-steel-ui.md;
      steel = ''
        ${builtins.readFile ./opencode/skills-steel.md}

        Paths to relative Steel documentation is relative to: '${inputs.steel}/docs/src/'
      '';
    };
    agents = {
      code-reviewer = ./opencode/code-reviewer.md;
    };
    rules = ./opencode/rules.md;
  };
}
