{
  config,
  pkgs,
  inputs,
  ...
}: let
  devFishPlugins = with pkgs.fishPlugins; [
    bass
    colored-man-pages
    pisces
    done
    sponge
    foreign-env
    fzf-fish
  ];
in {
  home.packages = devFishPlugins;
  programs = {
    starship.enableFishIntegration = true;

    fish = {
      interactiveShellInit = ''
        begin
          set fish_greeting
          set __done_notify_sound 1
        end

        function __direnv_export_eval --on-event fish_prompt
            begin
                begin
                    ${pkgs.direnv}/bin/direnv export fish
                end 1>| source
            end 2>| egrep -v -e "^direnv: export"
        end
      '';

      shellAliases = {
        kdiff = "kitty +kitten diff -o pygments_style=gruvbox-dark";
        kssh = "kitty +kitten ssh";
        kicat = "kitty +kitten icat";
        copy = "xclip -sel clip";
        psql = "pgcli";
        z = "j";
        gu = "${pkgs.gitui}/bin/gitui";
        watch = "watch -c -d";
        code = "nixGL code";
      };
      functions = {
        giffify = {
          body = "ffmpeg -i $video_file -r 15 -vf \"scale=1024:-1,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse\" $giff_name.gif";
          description = "giffify <video_file> <gif_name>";
          argumentNames = ["video_file" "gif_name"];
        };
        commandlinefu = {
          body = "curl -sX GET https://www.commandlinefu.com/commands/tagged/163/$command/json | jq -c \".[]\" | fzf --preview=\"jq -n {}\" | jq \".command\"";
          description = "commandlinefu search";
          argumentNames = ["command"];
        };
      };
      enable = true;
      plugins = [
        {
          name = "plugin-git";
          src = inputs.fish-plugin-git;
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
