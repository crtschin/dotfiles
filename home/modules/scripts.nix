{ pkgs, ... }:
let
  free-port = pkgs.writers.writePython3Bin "free-port" { } (builtins.readFile ./scripts/free-port.py);

  echoserver = pkgs.writeShellApplication {
    name = "echoserver";
    runtimeInputs = [ ];
    text = builtins.readFile ./scripts/echoserver.sh;
  };
  giffify = pkgs.writeShellApplication {
    name = "giffify";
    runtimeInputs = [ pkgs.ffmpeg ];
    text = builtins.readFile ./scripts/giffify.sh;
  };
  git-reb = pkgs.writeShellApplication {
    name = "git-reb";
    runtimeInputs = [ pkgs.git ];
    text = builtins.readFile ./scripts/git-reb.sh;
  };
  with-temp-postgres = pkgs.writeShellApplication {
    name = "with-temp-postgres";
    runtimeInputs = [  free-port pkgs.postgresql ];
    text = builtins.readFile ./scripts/with-temp-postgres.sh;
  };
in
{
  home.packages = [
    echoserver
    free-port
    giffify
    git-reb
    with-temp-postgres
  ];
}
