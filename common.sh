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
    sed -i "/$1=/d" "$basedir/common-env"
    printf '%s="%s"\n' "$1" "$2" >> "$basedir/common-env"
}
