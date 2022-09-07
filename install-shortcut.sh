#!/bin/bash
# Install desktop file to launch FAF from launcher

ICON_URL="https://www.faforever.com/images/faf-logo.png"

basedir="$(dirname $(readlink -f "${BASH_SOURCE[0]}"))"
cd "$basedir"

# fetch logo
wget -O faf-logo.png "$ICON_URL"

# write desktop file
echo "Writing desktop file..."
sed < net.hellomouse.iczero.faf-linux.desktop 's!{{SCRIPT_PATH}}!'"$basedir"'!g' | \
    tee "$HOME/.local/share/applications/net.hellomouse.iczero.faf-linux.desktop"

echo
echo Done

