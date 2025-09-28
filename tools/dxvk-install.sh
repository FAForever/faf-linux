#!/usr/bin/env bash
set -e
# usage: dxvk-install.sh <extracted>
# intended to be wrapped with launchwrapper-env

add-dll-override() {
    wine reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v "$1" /d "$2" /f
}

copy-dll() {
    cp --reflink=auto -v "$dxvk_path/$1/$2.dll" "$3"
}

install-dll() {
    if [[ "$has_x64" = "1" ]]; then
        copy-dll "x64" "$1" "$prefix/drive_c/windows/system32/"
        copy-dll "x32" "$1" "$prefix/drive_c/windows/syswow64/"
    else
        copy-dll "x32" "$1" "$prefix/drive_c/windows/system32/"
    fi
    add-dll-override "$1" "native"
}


if [[ ! -d "$1" ]]; then
    echo "source directory does not exist!"
    exit 1
else
    dxvk_path="$(readlink -f "$1")"
fi

if [[ -z "$WINEPREFIX" ]]; then
    echo "WINEPREFIX not provided"
    exit 1
fi
prefix="$(readlink -f "$WINEPREFIX")"
if [[ ! -d "$prefix/drive_c/windows/system32" ]]; then
    echo "prefix does not contain system32!"
    exit 1
fi
if [[ -d "$prefix/drive_c/windows/syswow64" ]]; then
    echo "prefix is 64-bit"
    has_x64="1"
else
    echo "prefix is 32-bit"
    has_x64="0"
fi

set -x
install-dll "d3d9"
install-dll "d3d10core"
install-dll "d3d11"
if [[ "$install_dxgi" = "1" ]]; then
    # probably shouldn't do this normally
    install-dll "dxgi"
fi
