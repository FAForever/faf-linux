#!/usr/bin/env bash
# Update specific components
# Currently supports updating dxvk and the faf client
set -e

basedir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
cd "$basedir"

source common-env
source ./common.sh

function update-dxvk() {
    local dxvk_version="$1"
    local dxvk_archive="dxvk-${dxvk_version}.tar.gz"
    local dxvk_extracted="dxvk-${dxvk_version}"
    local dxvk_url="https://github.com/doitsujin/dxvk/releases/download/v${dxvk_version}/${dxvk_archive}"

    if [[ -d "$dxvk_extracted" ]]; then
        echo "dxvk $dxvk_version already exists at $dxvk_extracted"
        echo "Not re-downloading."
    else
        block-print "Downloading dxvk"
        curlp -o "$dxvk_archive" "$dxvk_url"
        block-print "Extracting dxvk"
        tar -xvf "$dxvk_archive"
        rm "$dxvk_archive"
    fi

    block-print "Installing dxvk"
    install_dxgi=1 ./launchwrapper-env tools/dxvk-install.sh "$dxvk_extracted"

    write-env "dxvk_path" "$dxvk_extracted"

    write-env "dxvk_version_current" "$dxvk_version"

    echo
    echo "Done"
}

function update-dfc() {
    local dfc_version="$1"
    local dfc_archive="faf_unix_$(tr '.' '_' <<< "$dfc_version").tar.gz"
    local dfc_extracted="faf-client-${dfc_version}"
    local dfc_url="https://github.com/FAForever/downlords-faf-client/releases/download/v${dfc_version}/${dfc_archive}"

    if [[ -d "$dfc_extracted" ]]; then
        echo "FAF client $dfc_version already exists at $dfc_extracted"
        echo "Not re-downloading."
    else
        block-print "Downloading FAF client"
        curlp -o "$dfc_archive" "$dfc_url"
        block-print "Extracting FAF client"
        tar -xvf "$dfc_archive"
        rm "$dfc_archive"

        block-print "Applying access hacks"
        tee -a < faf-client-vm-options.txt "$dfc_extracted/faf-client.vmoptions"
    fi

    # update path in env anyways to allow for fast version switching
    echo "Switching to faf-client version $dfc_version"
    write-env "dfc_path" "$dfc_extracted"

    write-env "dfc_version_current" "$dfc_version"

    echo
    echo "Done"
}

function update-java() {
    local java_url="$1"

    block-print "Downloading java"
    curlp -o "java.tar.gz" "$java_url"
    block-print "Extracting java"
    local java_path="$(tar -tf "java.tar.gz" | head -n 1 | cut -d '/' -f 1)"
    if [[ -d "$java_path_orig" ]]; then
        echo "note: requested java version already exists, overwriting"
    fi
    tar -xvf "java.tar.gz"
    rm "java.tar.gz"

    write-env java_path "$java_path"
    write-env "java_download_url_current" "$java_url"

    echo
    echo "Done"
}

function update-steamrt() {
    local steamrt_url="$1"
    block-print "Downloading Steam Runtime"
    curlp -o "steamrt.tar.xz" "$steamrt_url"
    block-print "Extracting Steam Runtime"
    if [[ -e "steamrt.new" ]]; then
        echo "removing partially extracted files"
        rm -rf "steamrt.new"
    fi
    mkdir -p "steamrt.new"
    tar -C "steamrt.new" --strip-components=1 -xvf "steamrt.tar.xz"
    if [[ -e "steamrt" ]]; then
        mv "steamrt" "steamrt.old"
    fi
    mv "steamrt.new" "steamrt"
    if [[ -e "steamrt.old" ]]; then
        echo "cleaning up old directory..."
        rm -rf "steamrt.old"
    fi

    rm "steamrt.tar.xz"

    write-env "steamrt_download_url_current" "$steamrt_url"

    echo
    echo "Done"
}

function update-proton() {
    local proton_url="$1"

    block-print "Downloading Proton"
    curlp -o "proton.tar.gz" "$proton_url"
    block-print "Extracting Proton"
    local proton_path="$(tar -tf "proton.tar.gz" | head -n 1 | cut -d '/' -f 1)"
    if [[ -d "$proton_path" ]]; then
        echo "note: requested proton version already exists, overwriting"
    fi
    # exclude wine mono and gecko, they are somewhat large (~450MB combined) and we never use them
    tar \
        --exclude="$proton_path/files/share/wine/mono" \
        --exclude="$proton_path/files/share/wine/gecko" \
        --exclude="$proton_path/protonfixes" \
        -xvf "proton.tar.gz"
    rm "proton.tar.gz"

    write-env "proton_path" "$proton_path"
    write-env "proton_download_url_current" "$proton_url"

    echo
    echo "Done"
}

case "$1" in
    dxvk)
        shift
        update-dxvk "$@"
        ;;
    faf-client)
        shift
        update-dfc "$@"
        ;;
    java)
        shift
        update-java "$@"
        ;;
    steamrt)
        shift
        update-steamrt "$@"
        ;;
    proton)
        shift
        update-proton "$@"
        ;;
    *)
        echo "Unknown component $1"
        echo "Usage: $0 dxvk <dxvk version>"
        echo "       $0 faf-client <downlords-faf-client tag>"
        echo "       $0 java <java url>"
        echo "       $0 steamrt <steamrt url>"
        echo "       $0 proton <proton url>"
        ;;
esac
