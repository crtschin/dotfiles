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
        leader = "ctrl+space";
      };
    };
    skills = {
      steel-helix-ui = ./opencode/skills-helix-steel-ui.md;
      steel-helix-plugin = ./opencode/skills-helix-steel-plugin.md;
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
