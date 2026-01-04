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
      steel-threading = ./opencode/skills-steel-threading.md;
      helix-steel-buffer = ./opencode/skills-helix-steel-buffer.md;
      helix-steel-plugin = ''
        ${builtins.readFile ./opencode/skills-helix-steel-plugin.md}
        Helix-builtin steel functions can be found here: '${inputs.helix-crtschin}/steel-docs.md'.
      '';
      helix-steel-ui = ./opencode/skills-helix-steel-ui.md;
      steel = ''
        ${builtins.readFile ./opencode/skills-steel.md}
         Relative paths to Steel documentation is relative to: '${inputs.steel}/docs/src/'.
      '';
    };
    agents = {
      code-reviewer = ./opencode/code-reviewer.md;
    };
    rules = ./opencode/rules.md;
  };
}
