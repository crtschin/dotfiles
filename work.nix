{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  targets.genericLinux = {
    enable = true;
  };

  home = rec {
    username = "curtis";
  };

  programs = {
    git = {
      userName = "Curtis Chin Jen Sem";
      userEmail = "curtis.chinjensem@channable.com";
    };

    fish = {
      promptInit =
        ''
begin
  set fish_greeting
  set __done_notify_sound 1
  set LESS ' -R '

  # Non-NixOS setting
  set --export NIX_PATH $NIX_PATH:$HOME/.nix-defexpr/channels

  # Channable specific
  . ${../.config/channable.fish}
end

alias l "exa"
alias ll "exa -la"
alias ls "exa"
alias less "bat"
alias g "git"
alias e "eval $EDITOR"
alias ee "e (fzf)"
        ''
      ;
    };
  };
}
