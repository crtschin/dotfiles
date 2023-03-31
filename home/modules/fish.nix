{ config, pkgs, inputs, ... }:
let
  fish-pisces = pkgs.fishPlugins.buildFishPlugin rec {
    pname = "pisces";
    version = "0.7.0";
    src = inputs.fish-pisces;
  };

  fish-git-abbr = pkgs.fishPlugins.buildFishPlugin rec {
    pname = "fish-git-abbr";
    version = "0.2.1";
    src = inputs.fish-git-abbr;
  };

  devFishPlugins = with pkgs.fishPlugins; [
    fish-git-abbr
    fish-pisces
    done
    sponge
    foreign-env
    fzf-fish
  ];
in {
  home.packages = with pkgs; devFishPlugins;
  programs = {
    starship.enableFishIntegration = true;

    fish = {
      interactiveShellInit = ''
        begin
          set fish_greeting
          set __done_notify_sound 1
        end

        # abbr --add --global --position anywhere -- gbranch "(git branch --list --sort=-committerdate | string trim | fzf --preview=\"git log --stat -n 10 --decorate --color=always {}\")"

        function __direnv_export_eval --on-event fish_prompt
            begin
                begin
                    ${pkgs.direnv}/bin/direnv export fish
                end 1>| source
            end 2>| egrep -v -e "^direnv: export"
        end
        ''
      ;
      shellAliases = {
        kdiff = "kitty +kitten diff -o pygments_style=gruvbox-dark";
        kssh = "kitty +kitten ssh";
        kicat = "kitty +kitten icat";
        copy = "xclip -sel clip";
        gu = "${pkgs.gitui}/bin/gitui";
        watch = "watch -d";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";
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
          name = "z";
          src = pkgs.fetchFromGitHub {
            owner = "jethrokuan";
            repo = "z";
            rev = "e0e1b9dfdba362f8ab1ae8c1afc7ccf62b89f7eb";
            sha256 = "0dbnir6jbwjpjalz14snzd3cgdysgcs3raznsijd6savad3qhijc";
          };
        }
        {
          name = "bass";
          src = pkgs.fetchFromGitHub {
            owner = "edc";
            repo = "bass";
            rev = "2fd3d2157d5271ca3575b13daec975ca4c10577a";
            sha256 = "0mb01y1d0g8ilsr5m8a71j6xmqlyhf8w4xjf00wkk8k41cz3ypky";
          };
        }
      ];
    };
  };
}
