{
  config,
  pkgs,
  inputs,
  ...
}:
let
  devFishPlugins = with pkgs.fishPlugins; [
    bass
    pisces
    done
    sponge
    foreign-env
    fzf-fish
  ];
in
{
  home.packages = devFishPlugins;
  programs = {
    starship.enableFishIntegration = true;

    fish = {
      interactiveShellInit = ''
        begin
          set sponge_purge_only_on_exit true
          set fish_greeting
          set __done_notify_sound 1
          set --export SHELL ${pkgs.fish}/bin/fish
        end

        function __direnv_export_eval --on-event fish_prompt
            begin
                begin
                    ${pkgs.direnv}/bin/direnv export ${pkgs.fish}/bin/fish
                end 1>| source
            end 2>| egrep -v -e "^direnv: export"
        end
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
        z = "j";
        gu = "${pkgs.gitui}/bin/gitui";
        watch = "watch -c -d";
      };
      functions = {
        giffify = {
          body = "ffmpeg -i $video_file -r 15 -vf \"scale=1024:-1,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse\" $giff_name.gif";
          description = "giffify <video_file> <gif_name>";
          argumentNames = [
            "video_file"
            "gif_name"
          ];
        };
        commandlinefu = {
          body = "curl -sX GET https://www.commandlinefu.com/commands/tagged/163/$command/json | jq -c \".[]\" | fzf --preview=\"jq -n {}\" | jq \".command\"";
          description = "commandlinefu search";
          argumentNames = [ "command" ];
        };
        echoserver = {
          body = "while true; echo -e 'HTTP/1.1 200 OK\r\n' | nc -l $port; echo; end";
          description = "echo server";
          argumentNames = [ "port" ];
        };
      };
      enable = true;
      plugins = [
        {
          name = "plugin-git";
          src = pkgs.fishPlugins.plugin-git.src;
        }
        {
          name = "fish-puffer";
          src = inputs.fish-puffer;
        }
        {
          name = "fish-abbreviation-tips";
          src = inputs.fish-abbreviation-tips;
        }
      ];
    };
  };
}
