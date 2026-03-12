{
  config,
  pkgs,
  inputs,
  ...
}:
{
  programs = {
    starship = {
      enable = true;
      enableInteractive = true;
      settings = {
        aws = {
          disabled = true;
        };

        gcloud = {
          format = "on [$symbol($region)]($style) ";
          disabled = true;
        };

        # line_break = {
        #   disabled = true;
        # };

        battery = {
          full_symbol = "🔋";
          charging_symbol = "🔌";
          discharging_symbol = "⚡";
          display = [
            {
              threshold = 45;
              style = "bold yellow";
              discharging_symbol = "💦";
            }
            {
              threshold = 10;
              style = "bold red";
              discharging_symbol = "💀";
            }
          ];
        };

        character = {
          error_symbol = "[✖](bold red)";
        };

        cmd_duration = {
          min_time = 10000;
          format = " took [$duration]($style)";
        };

        directory = {
          truncation_length = 10;
          truncation_symbol = "…/";
          format = "[$path](bold $style)[$lock_symbol]($lock_style)[ with ](bold)";
        };

        elm = {
          format = "\\[[$symbol$branch]($style)\\]";
          symbol = "🌳";
        };

        env_var = {
          IN_NIX = {
            default = "";
            format = "[$env_value]($style)";
            style = "bold blue";
          };
        };

        git_branch = {
          format = "\\[[$symbol$branch]($style)\\]";
          symbol = "🌱";
          truncation_length = 30;
          ignore_branches = [ "master" ];
          style = "bold yellow";
        };

        git_commit = {
          commit_hash_length = 6;
          tag_disabled = false;
          tag_symbol = "🔖";
          style = "bright-white";
          format = "[\\[$hash$tag\\]]($style)";
        };

        git_status = {
          disabled = false;
          conflicted = "⚔️";
          ahead = "🏎️💨";
          behind = "🐢";
          diverged = "😵🏎️💨*$ahead_count🐢*$behind_count";
          untracked = "🛤️";
          stashed = "📦";
          modified = "📝";
          staged = "🗃️";
          renamed = "📛";
          deleted = "🗑️";
          style = "bright-white";
          format = "(\\[$all_status$ahead_behind\\])($style)";
        };

        haskell = {
          symbol = "λ";
          # format = "\\[[$symbol($ghc_version)]($style)\\]";
          format = "\\[[$symbol]($style)\\]";
        };

        hostname = {
          ssh_only = false;
          format = "<[$hostname]($style)>";
          trim_at = "-";
          style = "bold dimmed white";
          disabled = true;
        };

        memory_usage = {
          symbol = "🐏";
          format = "\\[$symbol[$ram(|$swap)]($style)\\]";
          threshold = 0;
          style = "bold dimmed white";
          disabled = true;
        };

        nodejs = {
          symbol = "⬢";
          format = "\\[[$symbol($version)]($style)\\]";
          disabled = true;
        };

        python = {
          symbol = "🐍";
          # format = "\\[[$symbol$pyenv_prefix($version)(\($virtualenv\))]($style)\\]";
          format = "\\[[$symbol$pyenv_prefix($version)(\($virtualenv\))]($style)\\]";
          disabled = true;
        };

        rust = {
          symbol = "🦀";
          version_format = "v$\{raw\}";
          # format = "\\[[$symbol$version]($style)\\]";
          format = "\\[[$symbol]($style)\\]";
          style = "bold green";
        };

        status = {
          format = "\\[[$symbol$status]($style)\\]";
          disabled = true;
        };

        nix_shell = {
          symbol = "🐚";
          format = "\\[[$symbol]($style)\\]";
          # format = "\\[[$symbol$state]($style)\\]";
          impure_msg = "[$name](bold blue)";
          pure_msg = "[$name](bold green)";
        };

        package = {
          disabled = false;
          symbol = "📦";
          version_format = "$\{raw\}";
          format = "\\[[$symbol$version]($style)\\]";
        };

        time = {
          time_format = "%T";
          format = "\\[🕙$time($style)\\]";
          style = "bright-white";
          disabled = true;
        };

        username = {
          style_user = "bold blue";
          format = "[$user]($style) in ";
          show_always = false;
        };

        vagrant = {
          disabled = true;
        };

        shlvl = {
          disabled = false;
          symbol = "↕️";
          format = "[$shlvl]($style) ";
          threshold = 3;
        };
      };
    };
  };
}
