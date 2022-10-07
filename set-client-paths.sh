#!/bin/bash
# Script to automatically set paths for the FAF client

basedir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
cd "$basedir"

source ./common.sh
load-env

client_prefs="$HOME/.faforever/client.prefs"

jq --arg game_path "$game_path" \
   --arg wrapper "$basedir/launchwrapper "'"%s"' \
   --arg prefs_path "$game_data_path/Game.prefs" \
   '.forgedAlliance += { installationPath: ($game_path), executableDecorator: ($wrapper), preferencesFile: ($prefs_path) }' \
   "$client_prefs" > "$client_prefs".new

mv "$client_prefs".new "$client_prefs"
echo "Done"
