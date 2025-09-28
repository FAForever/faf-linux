#!/usr/bin/env bash
# Compare versions against target versions ("versions" file) and update if requested

basedir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
cd "$basedir"

source ./common.sh

if [[ "$SCRIPT_DID_UPDATE" = "1" ]]; then
    echo "Scripts updated."
fi

do_notify="no"
update_ratelimit_file="common-env" # TODO: maybe use a different file?
if [[ "$1" = "autoupdate-notify" ]]; then
    # ratelimit updates to once per day
    last_checked="$(date -r "$update_ratelimit_file" '+%s')"
    if [[ $(( "$(date '+%s')" - "$last_checked" )) -lt 86400 ]]; then
        exit 0
    fi
    warn_prompt_headless="1"
    do_notify="yes"
    echo "faf-linux autoupdate: checking for updates"
fi

# ensure repository is up-to-date
current_branch="$(git branch --show-current)"
if ! git remote -v update; then
    warn-prompt "WARNING: unable to update git repository!"
    [[ "$do_notify" = "yes" ]] && exit 1
elif ! git merge-base --is-ancestor origin/"$current_branch" "$current_branch"; then
    if [[ "$do_notify" = "yes" ]]; then
        echo "faf-linux autoupdate: update found"
        notify-send -t 15000 'faf-linux' "An update is available. \
            Please run './update.sh' in $basedir" || echo "notify-send unavailable"
        exit 0
    fi
    if [[ "$SCRIPT_DID_UPDATE" = "1" ]]; then
        # ensure infinite loop does not happen
        echo "WARNING: failed to update?" 2>&1
        exit 1
    fi
    git pull --ff-only && echo "Update found, relaunching script..." && \
        SCRIPT_DID_UPDATE=1 exec ./update.sh "$@"
    warn-prompt "WARNING: update found but pull failed"
elif [[ "$do_notify" = "yes" ]]; then
    # we assume that if a user runs git pull manually, they know what they are doing
    echo "faf-linux autoupdate: no updates found"
    touch "$update_ratelimit_file"
    exit 0
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

if [[ "$dxvk_version_current" != "$dxvk_version_target" ]] && [[ "$dxvk_pin_version" != "1" ]]; then
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
