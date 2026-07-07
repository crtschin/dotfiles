{
  config,
  pkgs,
  inputs,
  ...
}:
let
  pkgsFishPlugins = with pkgs.fishPlugins; [
    bass
    done
    fish-you-should-use
    foreign-env
    fzf-fish
    pisces
    plugin-git
    puffer
    sponge
  ];
in
{
  home.packages = pkgsFishPlugins;

  # Shadows fish's bundled cabal completion, which runs `cabal <your args>
  # --list-options`. With `--` on the line that flag reaches the target, so
  # completing `cabal run app -- ./foo` would build and run the program.
  programs.fish.completions.cabal = ''
    function __fish_complete_cabal
        set -l cmd (commandline -pxc)
        contains -- -- $cmd; and return
        if test (count $cmd) -gt 1
            cabal $cmd[2..-1] --list-options
        else
            cabal --list-options
        end
    end

    complete -c cabal -a '(__fish_complete_cabal)'
  '';

  # just registers its clap completion with --exclusive, which kills fish's
  # file-path fallback, so `just build ./src` completes to nothing. The same
  # completer without --exclusive restores it.
  programs.fish.completions.just = ''
    complete -c just -a "(JUST_COMPLETE=fish just -- (commandline --current-process --tokenize --cut-at-cursor) (commandline --current-token))"
  '';

  programs = {
    starship.enableFishIntegration = true;
    bash = {
      enable = true;
      bashrcExtra = "PATH=$PATH:$HOME/.nix-profile/bin:$HOME/.cargo/bin";
    };
    fish = {
      interactiveShellInit = ''
        begin
          set sponge_purge_only_on_exit true
          set fish_greeting
          set __done_notify_sound 1
          set --export SHELL ${pkgs.fish}/bin/fish
          # autojump owns `j`, and so `z`. Only jump's zz binding is left.
          ${pkgs.jump}/bin/jump shell --bind=zz fish | source
        end

        # plugin-git keeps its ~170 git abbreviations inside __git.init, and the
        # conf.d file nixpkgs ships only calls that under a fisher install. It used to
        # not matter because the abbreviations were universal and persisted on their
        # own, but fish 4 removed universal abbreviations, so they have to be created
        # per session now.
        if functions -q __git.init
            __git.init
        end

        fish_add_path ${config.home.homeDirectory}/.opencode/bin
      '';

      shellAliases = {
        gcloud-operations-log = "gcloud compute operations list --format=\":(TIMESTAMP.date(tz=LOCAL))\" --sort-by=TIMESTAMP";
        with-cachix-key = "vaultenv --secrets-file (echo \"cachix#signing-key\" | psub) -- ";
        kdiff = "kitty +kitten diff -o pygments_style=gruvbox-dark";
        kssh = "kitty +kitten ssh";
        kicat = "kitty +kitten icat";
        vscode = "code --ozone-platform=wayland";
        copy = "xclip -sel clip";
        psql = "pgcli";
        lla = "eza -la --group-directories-first --icons=auto --smart-group --no-permissions --no-user";
        llaa = "eza -la --group-directories-first --icons=auto --smart-group";
        z = "j";
        gt = "${pkgs.gitui}/bin/gitui";
        ld = "${pkgs.lazydocker}/bin/lazydocker";
        lw = "${pkgs.lazyworktree}/bin/lazyworktree";
        mkdir = "mkdir -p -v";
        watch = "watch -c -d";
      };
      enable = true;
      # home.packages already puts these plugins' vendor_conf.d on fish's load
      # path. Listing them here too would source each one twice.
    };
  };
}
