{
  config,
  lib,
  pkgs,
  inputs,
  std,
  ...
}:
{
  programs.zed-editor = {
    enable = false;

    extensions = [
      "nix"
      "haskell"
      "cabal"
      "gruvbox"
      "docker-compose"
      "dockerfile"
      "toml"
      "make"
      "basher"
      "git-firefly"
    ];

    extraPackages = with pkgs; [
      nixd
      basedpyright
      ruff
      marksman
      docker-language-server
      haskell-language-server
      codebook
    ];

    userSettings = {
      theme = {
        mode = "dark";
        light = "Gruvbox Light Soft";
        dark = "Gruvbox Dark Soft";
      };

      buffer_font_family = pkgs.rice.font.monospace.name;
      buffer_font_size = pkgs.rice.font.monospace.size;
      ui_font_size = pkgs.rice.font.normal.size;

      helix_mode = true;
      base_keymap = "VSCode";

      relative_line_numbers = true;
      current_line_highlight = "all";
      vertical_scroll_margin = 4;
      scroll_beyond_last_line = "one_page";
      wrap_guides = [
        80
        100
      ];
      soft_wrap = "none";
      cursor_blink = true;
      show_whitespaces = "selection";

      autosave = "on_focus_change";
      format_on_save = "on";
      ensure_final_newline_on_save = true;
      remove_trailing_whitespace_on_save = true;

      indent_guides = {
        enabled = true;
        coloring = "indent_aware";
      };

      inlay_hints = {
        enabled = true;
        show_type_hints = true;
        show_parameter_hints = true;
        show_other_hints = true;
      };

      hover_popover_enabled = true;
      use_autoclose = true;

      file_finder = {
        include_ignored = false;
      };

      tab_bar = {
        show = true;
      };

      tabs = {
        git_status = true;
        file_icons = true;
      };

      load_direnv = "shell_hook";
      auto_update = false;

      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      features = {
        edit_prediction_provider = "none";
      };
      disable_ai = true;

      lsp = {
        nixd = {
          binary = {
            path = lib.getExe pkgs.nixd;
          };
        };

        basedpyright = {
          binary = {
            path = "${pkgs.basedpyright}/bin/basedpyright-langserver";
            arguments = [ "--stdio" ];
          };
          settings = {
            basedpyright.analysis = {
              autoSearchPaths = true;
              diagnosticMode = "openFilesOnly";
            };
          };
        };

        ruff = {
          binary = {
            path = lib.getExe pkgs.ruff;
            arguments = [
              "server"
              "--preview"
            ];
          };
        };

        hls = {
          binary = {
            path = "${pkgs.haskell-language-server}/bin/haskell-language-server-wrapper";
            arguments = [ "--lsp" ];
          };
          settings = {
            haskell = {
              sessionLoading = "multipleComponents";
              rename = {
                config = "crossModule";
              };
            };
          };
        };

        marksman = {
          binary = {
            path = lib.getExe pkgs.marksman;
          };
        };

        mdpls = {
          binary = {
            path = "mdpls";
          };
          settings = {
            markdown.preview = {
              auto = false;
              browser = "firefox";
            };
          };
        };

        docker-language-server = {
          binary = {
            path = lib.getExe pkgs.docker-language-server;
            arguments = [
              "start"
              "--stdio"
            ];
          };
          settings = {
            docker-language-server = {
              telemetry = "off";
            };
          };
        };
      };

      languages = {
        "Nix" = {
          language_servers = [ "nixd" ];
          tab_size = 2;
        };
        "Python" = {
          language_servers = [
            "basedpyright"
            "ruff"
          ];
          format_on_save = "on";
          formatter = {
            language_server = {
              name = "ruff";
            };
          };
        };
        "Haskell" = {
          language_servers = [ "hls" ];
          tab_size = 2;
        };
        "Cabal" = {
          language_servers = [ "hls" ];
          tab_size = 2;
          preferred_line_length = 80;
          wrap_guides = [ 80 ];
        };
        "Markdown" = {
          language_servers = [
            "marksman"
            "mdpls"
          ];
          soft_wrap = "preferred_line_length";
          preferred_line_length = 80;
          wrap_guides = [ 80 ];
          format_on_save = "off";
        };
        "Git Commit" = {
          soft_wrap = "preferred_line_length";
          preferred_line_length = 72;
          wrap_guides = [
            50
            72
          ];
        };
        "Dockerfile" = {
          language_servers = [ "docker-language-server" ];
        };
        "Docker Compose" = {
          language_servers = [ "docker-language-server" ];
        };
      };
    };

    userKeymaps = [
      {
        context = "Editor";
        bindings = {
          "ctrl-p" = "file_finder::Toggle";
          "ctrl-shift-p" = "command_palette::Toggle";
          "ctrl-a" = "editor::SelectAll";
          "ctrl-d" = "editor::SelectNext";
          "ctrl-shift-a" = "editor::SelectAllMatches";
        };
      }
      {
        context = "Workspace";
        bindings = {
          "space o" = "file_finder::Toggle";
          "space e" = "workspace::ToggleLeftDock";
          "space space" = "workspace::Save";
          "shift-h" = "pane::ActivatePreviousItem";
          "shift-l" = "pane::ActivateNextItem";
        };
      }
    ];
  };
}
