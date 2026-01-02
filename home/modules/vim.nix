{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  programs = {
    neovim = {
      enable = true;
      extraConfig = "";
      extraLuaConfig = builtins.readFile ../../.config/nvim/init.lua;
      extraPackages = with pkgs; [
        # Language Servers (matching Helix config)
        harper
        marksman
        dockerfile-language-server-nodejs
        simple-completion-language-server
        haskell-language-server
        basedpyright
        ruff

        # Tools
        ripgrep # For telescope
        fd
      ];
      plugins =
        with pkgs.vimPlugins;
        [
          # Theme
          gruvbox-material

          # UI Components
          lualine-nvim        # Status line
          bufferline-nvim     # Buffer line
          indent-blankline-nvim # Indent guides
          gitsigns-nvim       # Git gutters
          which-key-nvim      # Key binding helper
          telescope-nvim      # File picker
          telescope-ui-select-nvim
          plenary-nvim        # Dependency for telescope/others
          nvim-web-devicons   # Icons

          # Navigation & Editing
          harpoon             # Workplace navigation
          oil-nvim            # File system editor
          flash-nvim          # Motions (replacing some Helix jump modes)

          # LSP & Completion
          nvim-lspconfig
          cmp-nvim-lsp
          cmp-buffer
          cmp-path
          cmp-cmdline
          nvim-cmp
          luasnip
          cmp_luasnip
          lean-nvim

          # Formatting
          conform-nvim

          # Syntax
          nvim-treesitter.withAllGrammars
        ];
      viAlias = true;
      vimAlias = true;
    };
  };
}
