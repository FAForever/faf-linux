#!/bin/bash
# Update specific components
# Currently supports updating dxvk and the faf client
set -e

basedir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
cd "$basedir"

source common-env
source ./common.sh

function update-dxvk() {
   dxvk_version="$1"
   dxvk_archive="dxvk-${dxvk_version}.tar.gz"
   dxvk_extracted="dxvk-${dxvk_version}"
   dxvk_url="https://github.com/doitsujin/dxvk/releases/download/v${dxvk_version}/${dxvk_archive}"

   if [[ -d "$dxvk_extracted" ]]; then
      echo "dxvk $dxvk_version already exists at $dxvk_extracted"
      echo "Not re-downloading."
   else
      block-print "Downloading dxvk"
      wget -O "$dxvk_archive" "$dxvk_url"
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
   dfc_version="$1"
   dfc_archive="faf_unix_$(tr '.' '_' <<< "$dfc_version").tar.gz"
   dfc_extracted="faf-client-${dfc_version}"
   dfc_url="https://github.com/FAForever/downlords-faf-client/releases/download/v${dfc_version}/${dfc_archive}"

   if [[ -d "$dfc_extracted" ]]; then
      echo "FAF client $dfc_version already exists at $dfc_extracted"
      echo "Not re-downloading."
   else
      block-print "Downloading FAF client"
      wget -O "$dfc_archive" "$dfc_url"
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
   java_url="$1"

   block-print "Downloading java"
   wget -O "java.tar.gz" "$java_url"
   block-print "Extracting java"
   java_path="$(tar -tf "java.tar.gz" | head -n 1 | cut -d '/' -f 1)"
   if [[ -d "$java_path_orig" ]]; then
      echo "note: requested java version already exists"
   fi
   tar -xvf "java.tar.gz"
   rm "java.tar.gz"

   write-env java_path "$java_path"
   write-env "java_download_url_current" "$java_url"

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
   *)
      echo "Unknown component $1"
      echo "Usage: $0 dxvk <dxvk version>"
      echo "       $0 faf-client <downlords-faf-client tag>"
      echo "       $0 java <java url> <javafx url>"
      ;;
esac
