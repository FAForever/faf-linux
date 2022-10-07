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

      pushd "$dxvk_extracted"
      # patch dxvk to work with proton
      patch setup_dxvk.sh "$basedir/setup_dxvk.sh.patch"
      popd
   fi

   block-print "Installing dxvk"
   "$basedir/launchwrapper-env" "$basedir/$dxvk_extracted/setup_dxvk.sh" install
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
   write-env "dfc_path" "$dfc_extracted"

   write-env "dfc_version_current" "$dfc_version"

   echo
   echo "Done"
}

function update-java() {
   java_url="$1"
   javafx_url="$2"

   block-print "Downloading java"
   wget -O "java.tar.gz" "$java_url"
   block-print "Extracting java"
   java_path_orig="$(tar -tf "java.tar.gz" | head -n 1 | cut -d '/' -f 1)"
   if [[ -d "$java_path_orig" ]]; then
      echo "note: requested java version already exists"
   fi
   tar -xvf "java.tar.gz"
   block-print "Downloading javafx"
   wget -O "javafx.zip" "$javafx_url"

   block-print "Extracting javafx"
   pushd "$java_path_orig"
   # what follows are multiple extremely bad hacks
   unzip "../javafx.zip"
   javafx_jmods_dir=("javafx-jmods-"*)
   cp -rv "$javafx_jmods_dir/"* "jmods/"
   rm -r "$javafx_jmods_dir"
   # unfortunately, adoptopenjdk does not provide java builds with javafx
   # even more unfortunately, the openjfx "sdk" segfaults immediately
   # to get a working JRE with javafx, we have to manually rebuild one with jlink
   block-print "Rebuilding jre"
   jmods="$(ls jmods | sed -E 's/\.jmod$//' | tr '\n' ',')"
   java_path="${java_path_orig}-javafx"
   echo "jlink..."
   if [[ -d "../$java_path" ]]; then
      echo "removing old built jre"
      rm -rf "../$java_path"
   fi
   bin/jlink -p jmods --add-modules "$jmods" --output "../$java_path"
   popd
   write-env java_path "$java_path"
   echo "deleting old downloaded java..."
   rm -rf "$java_path_orig"
   rm "java.tar.gz"
   rm "javafx.zip"

   write-env "java_download_url_current" "$java_url"
   write-env "javafx_download_url_current" "$javafx_url"

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
