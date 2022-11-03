#!/bin/bash
# Compare versions against target versions ("versions" file) and update if requested

basedir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
cd "$basedir"

source ./common.sh

# ensure repository is up-to-date
current_branch="$(git branch --show-current)"
if ! git remote -v update; then
    warn-prompt "WARNING: unable to update git repository!"
elif ! git merge-base --is-ancestor origin/"$current_branch" "$current_branch"; then
    git pull --ff-only && echo "Update found, relaunching script..." && exec ./update.sh "$@"
    warn-prompt "WARNING: update found but pull failed"
fi
echo

# variables
load-env

# did user want us to update?
perform_update="no"
if [[ "$1" = "perform" ]]; then
    perform_update="yes"
fi

has_updates="no"

if [[ "$dxvk_version_current" != "$dxvk_version_target" ]]; then
    echo "DXVK version $dxvk_version_current is installed, but does not match target version ($dxvk_version_target)"
    has_updates="yes"
    if [[ "$perform_update" = "yes" ]]; then
        ./update-component.sh dxvk "$dxvk_version_target"
    fi
fi

if [[ "$dfc_version_current" != "$dfc_version_target" ]]; then
    echo "FAF client version $dfc_version_current is installed, but does not match target version ($dfc_version_target)"
    has_updates="yes"
    if [[ "$perform_update" = "yes" ]]; then
        ./update-component.sh faf-client "$dfc_version_target"
    fi
fi

if [[ "$java_download_url_current" != "$java_download_url_target" ]]; then
    echo "Java runtime from URL $java_download_url_current is installed, but does not match target ($java_download_url_target)"
    has_updates="yes"
    if [[ "$perform_update" = "yes" ]]; then
        ./update-component.sh java "$java_download_url_target"
    fi
fi

if [[ "$perform_update" != "yes" ]] && [[ "$has_updates" = "yes" ]]; then
    echo ""
    echo "Updates were found but were not installed."
    echo "To install updates, run './update.sh perform'."
fi

if [[ "$has_updates" = "no" ]]; then
    echo "All installed versions match target versions."
fi
