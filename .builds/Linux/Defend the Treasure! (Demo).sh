#!/bin/sh
echo -ne '\033c\033]0;Gmtk-jam-2023\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Defend the Treasure! (Demo).x86_64" "$@"
