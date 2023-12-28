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

# ensure all libraries passed are present in 32bit versions
function ensure-lib() {
    for lib in "$@"; do
        # check presence on native system
        if [[ 0 = $(ldconfig -p | grep $lib | grep /lib/ | wc -l) ]]; then
            # check presence within proton
            if [[ 0 = $(ls "$PROTON_PATH/$proton_wine_subdir/lib/$lib*" | wc -l) ]]; then
                echo "Could not find $lib (32bit)" >&2
                error=1
                continue
            fi
        fi
        echo "- $lib (32-bit)"
    done
    if [ $error ];then
        exit 1
    fi
}

# ensure all libraries passed are present in 64bit versions
function ensure-lib64() {
    for lib in "$@"; do
        # check presence on native system
        if [[ 0 = $(ldconfig -p | grep $lib | grep /lib64/ | wc -l) ]]; then
            # check presence within proton
            if [[ 0 = $(ls "$PROTON_PATH/$proton_wine_subdir/lib64/$lib*" | wc -l) ]]; then
                echo "Could not find $lib (64bit)" >&2
                error=1
                continue
            fi
        fi
        echo "- $lib (64-bit)"
    done
    if [ $error ];then
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
    if [[ ! "$warn_prompt_headless" = 1 ]]; then
        read -n 1 -s -r -p "Press any key to continue, or Ctrl-C to cancel..."
    fi
}

function load-env() {
    source ./versions
    if ! source ./common-env; then
        echo "Environment file does not exist!" >&2
        echo "Did you run setup.sh?" >&2
        exit 1
    fi
}
