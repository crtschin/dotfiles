style:
  find **/*.nix | xargs -I{} nixfmt {}

hm command target:
  home-manager {{command}} --flake .#{{target}}

news target: (hm "news" target)
switch target: (hm "switch" target)

update +args:
  nix flake update {{args}}

# Install/update the local Helix Steel plugins (cogs) listed in the flake, via forge
install-plugins:
  #!/usr/bin/env bash
  set -euo pipefail
  for dir in $(nix eval --raw --apply 'ps: toString (builtins.attrValues ps)' .#helixSteelPlugins); do
    echo "==> forge install: $dir"
    (cd "$dir" && forge install)
  done

save:
  git add -u
  git commit -m "Update"
  git push
