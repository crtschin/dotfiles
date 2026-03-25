#!/usr/bin/env bash
ffmpeg -i "$1" -r 15 -vf "scale=1024:-1,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" "$2.gif"
