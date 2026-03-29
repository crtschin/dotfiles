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
  git-swing = pkgs.writeShellApplication {
    name = "git-swing";
    runtimeInputs = [ pkgs.git ];
    text = builtins.readFile ./scripts/git-swing.sh;
  };
  git-reroot = pkgs.writeShellApplication {
    name = "git-reroot";
    runtimeInputs = [ pkgs.git ];
    text = builtins.readFile ./scripts/git-reroot.sh;
  };
  git-reauthor = pkgs.writeShellApplication {
    name = "git-reauthor";
    runtimeInputs = [ pkgs.git ];
    text = builtins.readFile ./scripts/git-reauthor.sh;
  };
  git-to-worktree = pkgs.writeShellApplication {
    name = "git-to-worktree";
    runtimeInputs = [ pkgs.git ];
    text = builtins.readFile ./scripts/git-to-worktree.sh;
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
    git-swing
    git-reroot
    git-reauthor
    git-to-worktree
    with-temp-postgres
  ];
}
