{ pkgs, ... }:

let
  overlayed = pythonPackages: with pythonPackages; rec {};

  devPythonPackages = ps: with ps; [ ];

  devPython = pkgs.python3.withPackages(ps: with overlayed ps;
    [ ] ++ devPythonPackages ps);
in {
  home.packages = with pkgs; [
    devPython
  ];
}
