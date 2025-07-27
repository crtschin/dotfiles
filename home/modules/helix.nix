{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
in
{
  programs = {
    helix = {
      enable = true;
      package = (builtins.getFlake "github:helix-editor/helix").packages.${pkgs.system}.default;
      settings = {
        theme = "gruvbox_dark_soft";
        editor = {
          line-number = "relative";
          lsp.display-messages = true;
        };
      };
      languages = {
        # language-server.haskell-language-server = {
        #   command = "haskell-language-server";
        #   args = [
        #     "--stdio"
        #     "--tsserver-path=${typescript}/lib/node_modules/typescript/lib"
        #   ];
        # };
        # language = [
        #   {
        #     name = "rust";
        #     auto-format = false;
        #   }
        # ];
      };
    };
  };
}
