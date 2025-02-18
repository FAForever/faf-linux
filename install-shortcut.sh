#!/bin/bash
# Install desktop file to launch FAF from launcher

ICON_URL="https://www.faforever.com/images/faf-logo.png"

basedir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
cd "$basedir"

# fetch logo
wget -O faf-logo.png "$ICON_URL"

# write desktop file
echo "Writing desktop file..."
dest_path="$HOME/.local/share/applications/com.faforever.faf-linux.desktop"
tee "$dest_path" <<EOF
[Desktop Entry]
Name=Forged Alliance Forever
Comment=Lobby client for Supreme Commander: Forged Alliance (faf-linux)
Exec=$basedir/run
Type=Application
Icon=$basedir/faf-logo.png
StartupWMClass=com.faforever.client.FafClientApplication
Categories=Network;Game;
Keywords=faf
EOF
chmod a+x "$dest_path"

if [[ -f "$HOME/.local/share/applications/net.hellomouse.iczero.faf-linux.desktop" ]]; then
    echo "Removing old entry"
    rm -v "$HOME/.local/share/applications/net.hellomouse.iczero.faf-linux.desktop"
fi
echo
echo Done
