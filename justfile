style:
  find **/*.nix | xargs -I{} nixfmt {}

hm command target:
  home-manager {{command}} --flake .#{{target}}

news target: (hm "news" target)
switch target: (hm "switch" target)

update target:
  nix flake update --flake .
