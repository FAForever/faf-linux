# Common functions shared between scripts
# This file should be sourced

function block-print() {
    echo "============================================================"
    printf "$@"
    echo
    echo "============================================================"
}

function ensure-bin() {
    if ! "$@" > /dev/null; then
        echo "Command '$@' failed. Please install '$1' from your distribution's package manager." >&2
        exit 1
    fi
}

function ensure-path() {
    if [[ ! -d "$1" ]]; then
        echo "$2" >&2
        exit 1
    fi
}

function write-env() {
    sed -i "/^$1=/d" "$basedir/common-env"
    printf '%s="%s"\n' "$1" "$2" >> "$basedir/common-env"
}

function warn-prompt() {
    echo "$@" >&2
    read -n 1 -s -r -p "Press any key to continue, or Ctrl-C to cancel..."
}

function load-env() {
    source ./versions
    if ! source ./common-env; then
        echo "Environment file does not exist!" >&2
        echo "Did you run setup.sh?" >&2
        exit 1
    fi
}
