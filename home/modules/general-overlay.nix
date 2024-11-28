{
  config,
  pkgs,
  inputs,
  ...
}:
let
  overlay = self: super: {
    nix-direnv = self.stdenv.mkDerivation rec {
      pname = "nix-direnv";
      version = "2.2.1";

      src = inputs.nix-direnv;

      # Substitute instead of wrapping because the resulting file is
      # getting sourced, not executed:
      postPatch = ''
        sed -i "1a NIX_BIN_PREFIX=${self.nix}/bin/" direnvrc
        substituteInPlace direnvrc --replace "grep" "${self.gnugrep}/bin/grep"
      '';

      installPhase = ''
        runHook preInstall
        install -m500 -D direnvrc $out/share/nix-direnv/direnvrc
        runHook postInstall
      '';

      meta = with self.lib; {
        description = "A fast, persistent use_nix implementation for direnv";
        homepage = "https://github.com/nix-community/nix-direnv";
        license = licenses.mit;
        platforms = platforms.unix;
        maintainers = with maintainers; [
          mic92
          bbenne10
        ];
      };
    };
  };
in
{
  nixpkgs.overlays = [ overlay ];
}
