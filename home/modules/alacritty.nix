{
  config,
  pkgs,
  inputs,
  ...
}:
{
  programs = {
    tmux = {
      enable = true;
      clock24 = true;
      historyLimit = 5000;
      prefix = "C-Space";
      extraConfig = ''
        bind-key -n C-t new-window
        bind-key -n C-w kill-window
        bind-key -n C-Up previous-window
        bind-key -n C-Down next-window
        bind-key -n C-x kill-pane
        bind-key -n C-n split-window -v
        bind-key -n C-M-n split-window -h
        bind-key -n M-Up select-pane -U
        bind-key -n M-Down select-pane -D
        bind-key -n M-Left select-pane -L
        bind-key -n M-Right select-pane -R

        bind -n M-s setw synchronize-panes

        # Prevent vim from swallowing ctrl arrows
        set-window-option -g xterm-keys on

        # Use the screen terminal
        set -g default-terminal screen

        # Apply Tc
        set-option -ga terminal-overrides \",screen:Tc\"
        set -g mouse on
        set -g focus-events on
      '';
    };
    alacritty = {
      enable = true;
      settings = {
        colors = {
          primary = {
            background = "0x282828";
            foreground = "0xdfbf8e";
          };
          normal = {
            black = "0x665c54";
            red = "0xea6962";
            green = "0xa9b665";
            yellow = "0xe78a4e";
            blue = "0x7daea3";
            magenta = "0xd3869b";
            cyan = "0x89b482";
            white = "0xdfbf8e";
          };
          bright = {
            black = "0x928374";
            red = "0xea6962";
            green = "0xa9b665";
            yellow = "0xe3a84e";
            blue = "0x7daea3";
            magenta = "0xd3869b";
            cyan = "0x89b482";
            white = "0xdfbf8e";
          };
        };
        font = {
          normal.family = "${pkgs.rice.font.monospace.name}";
          normal.style = "Regular";
          bold.family = "${pkgs.rice.font.monospace.name}";
          bold.style = "Bold";
          italic.family = "${pkgs.rice.font.monospace.name}";
          italic.style = "Light Italic";
          size = 13;
        };
        mouse = {
          hide_when_typing = true;
        };
        selection = {
          semantic_escape_chars = ",│`|:\"' ()[]{}<>";
          save_to_clipboard = false;
        };
        cursor = {
          style = "Block";
          unfocused_hollow = true;
        };
        terminal.shell = {
          program = "${pkgs.fish}/bin/fish";
          args = [ "--command=${pkgs.tmux}/bin/tmux" ];
        };
      };
    };
  };
}
