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
    };
    skills = {
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
