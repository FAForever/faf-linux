#!/bin/bash
# Install desktop file to launch FAF from launcher

ICON_URL="https://www.faforever.com/images/faf-logo.png"

basedir="$(dirname $(readlink -f "${BASH_SOURCE[0]}"))"
cd "$basedir"

# fetch logo
wget -O faf-logo.png "$ICON_URL"

# write desktop file
echo "Writing desktop file..."
dest_path="$HOME/.local/share/applications/net.hellomouse.iczero.faf-linux.desktop"
tee "$dest_path" <<EOF
[Desktop Entry]
Name=Forged Alliance Forever
Comment=Lobby client for Supreme Commander: Forged Alliance (iczero/faf-linux)
Exec=$basedir/run
Type=Application
Icon=$basedir/faf-logo.png
EOF
chmod a+x "$dest_path"

echo
echo Done
