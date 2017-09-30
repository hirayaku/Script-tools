#!/bin/bash

# hbackup - create backup directory given the src and dest directories.
# 1) When backing up, hbackup will create copies suffixed with `.bak[0-9]*` to distinguish versions
# 2) When restoring from the backup, user can see the info of each backup'd directory 
#    to decide which one to copy.
# 3) Previous configuration is written into the `~/.hbackup` folder, so that user won't have to
#    assign backup and src dir everytime hbackup is used.
# 4) hbackup also accepts a user-provided conf file to support more flexible behaviors.

# This is my attempt to write not-toy-like bash scripts (like `touchctl`).
# TODO:
#   - Add `-c <conf>` support
#   - add options like -L, -P to indicate whether to follow the soft link or not
#   - add `-v` verbose output

num_args=$#
script_name=$0
help_text="
$script_name usage:
\n$script_name  [-h|l|f|i] [-d [-c] <dest_dir>] [-s <src_dir>] [-m <string>]
\n              [backup|restore]
\n
\n  -h      print help text
\n
\n  -l      print current configurations
\n
\n  -f      force overwrite when restoring
\n
\n  -i      interactive mode; prompt before overwriting
\n
\n  -b  <backup_dir>
\n          set destination directory to backup the files to.
\n          if not given by the user, default directory will be the result of \`\$(pwd)/../\`
\n
\n  -B  <backup_dir>
\n          create the directory if not exist
\n
\n  -s  <src_dir>
\n          set original directory to copy the files from.
\n          if not given by the user, default directory will be the child dir
\n          ended with \`.bak\` in the dest_dir.
\n  -m  <string>
\n          add your description attached to created backup
\n
\n  -c  <external_conf> (not supported yet)
\n          use user-provided conf
\n
\n  backup  backup the contents in <src_dir> into <dest_dir>
\n
\n  restore restore the contents from <dest_dir> into <dest_dir>
"
help_text_refined="
$script_name usage:
\n$script_name  [-h|l|f] [-d [-c] <dest_dir>] [-s <src_dir>] [backup|restore]
"
info="Control the source files for Xilinx SDK to avoid the buggy IDE"
version="0.1"
author="hirayaku"
home_conf_dir=`realpath ~/.hbackup`
home_conf="$home_conf_dir/history"
if ! [ -d "$home_conf_dir" ]; then
    mkdir "$home_conf_dir"
fi

function how_to_use {
    echo -e $help_text_refined
    exit $1
}
function check_state {
    err_code=$?
    if [ $err_code -ne 0 ]; then
        echo "Internal script error: $error_code"
        exit $err_code
    fi
}
# 1st argument is the dir to backup, 2nd argument is target dir
function get_bak_index {
    bak_dir="$1"
    bak_dir_base=`basename $1`
    target_dir="$2"
    # extract numbers in the directories with a pattern of 'xxx.bak[numbers]/'
    indices=`ls $target_dir | grep -P "${bak_dir_base}\.bak[0-9]+/*$" | sed "s/${bak_dir_base}\.bak*[^0-9]\([0-9]\+\)\/*$/\1/" | sort -n`
    candidate=0
    for i in $indices; do
        if [ $candidate -lt $i ]; then
            break
        elif [ $candidate -gt $i ]; then
            candidate=$((i+1))
        else
            candidate=$((candidate + 1))
        fi
    done
    echo $candidate
}
# 1st argument is the dir to backup, 2nd argument is target dir
function get_bak_files {
    bak_dir="$1"
    bak_dir_base=`basename $1`
    target_dir="$2"
    # extract numbers in the directories with a pattern of 'xxx.bak[numbers]/'
    baks=`ls $target_dir | grep -P "${bak_dir_base}\.bak[0-9]+/*$"`
    echo $baks
}
# 1st argument is input string split by \n, 2nd is the output string
# Require user to input a choice
function get_string_seg {
    index=0
    for s in $1; do
        echo "${index}) $s"
        str_array[$index]=$s
        index=$((index+1))
    done
    [ $index -eq 0 ] && echo "Error: No backup found!" && exit 4

    printf "Select one: "
    while true; do
        read choice
        if [ -z $choice ] && [ $index -eq 1 ]; then
            choice=0
            echo "Defaul to 0)"
            break
        fi
        if [ $choice -lt $index ] && [ $choice -ge 0 ]; then
            break
        else
            echo "Illegal input: should be an integers between 0 ~ $index"
            printf "Select one to restore from: "
        fi
    done

    eval out_string=${str_array[$choice]}
    printf "Restoring from $out_string...\n"
    return 0
}

if [ $num_args -eq 0 ]; then
    how_to_use 0
fi

_BAK_CONF="$home_conf"
[ -f "$home_conf" ] && source "$home_conf"
if [ -z $SRC ]; then
    _BAK_SRC_DIR=`pwd`
else
    _BAK_SRC_DIR=$SRC
fi
if [ -z $DEST ]; then
    _BAK_DEST_DIR=$(realpath $_BAK_SRC_DIR/..)
else
    _BAK_DEST_DIR=$DEST
fi

# Default states
_BAK_HELP='NO'
_BAK_LIST='NO'
_BAK_FORCE='NO'
_BAK_INTERACTIVE='NO'
_BAK_SET_DEST='NO'
_BAK_CREATE_DESTDIR='NO'
_BAK_SET_SRC='NO'
_BAK_ACTION=''
_BAK_SET_MSG='NO'
_BAK_MSG=''
_OPT_STATE=''
check_state

# get options
for opt in "$@"; do
    # when the previous opt is -s|b|B, later opt should be the directory path
    case "$_OPT_STATE" in
        set_dest)
            _BAK_DEST_DIR=`realpath $opt`
            _OPT_STATE=''
            shift
            continue
            ;;
        set_src)
            _BAK_SRC_DIR=`realpath $opt`
            _OPT_STATE=''
            shift
            continue
            ;;
        set_msg)
            _BAK_MSG=$opt
            _OPT_STATE=''
            shift
            continue
            ;;
        *)
            ;;
    esac

    case $opt in
        -h*)
            _BAK_HELP='YES'
            shift
            ;;
        -l*)
            _BAK_LIST='YES'
            shift
            ;;
        -f*)
            _BAK_FORCE='YES'
            shift
            ;;
        -i*)
            _BAK_INTERACTIVE='YES'
            shift
            ;;
        -b)
            _BAK_SET_DEST='YES'
            _OPT_STATE='set_dest'
            shift
            ;;
        -B)
            _BAK_SET_DEST='YES'
            _BAK_CREATE_DESTDIR='YES'
            _OPT_STATE='set_dest'
            shift
            ;;
        -s*)
            _BAK_SET_SRC='YES'
            _OPT_STATE='set_src'
            shift
            ;;
        backup|restore)
            if [ -z $ACTION ]; then
                ACTION=$opt
            else
                echo "Error: Do not assign more than one action"
                how_to_use 2
            fi
            shift
            ;;
        -m*)
            _BAK_SET_MSG='YES'
            _OPT_STATE='set_msg'
            shift
            ;;
        # not matched by any above
        *)
            echo "Error: Unknown option: $opt"
            how_to_use 1
    esac
done

if [ $_BAK_HELP == 'YES' ]; then
    echo -e $help_text
    exit 0
fi

# check if appointed directories exist
_BAK_DEST_PARENT=$_BAK_DEST_DIR
_BAK_DEST_DIR="$_BAK_DEST_PARENT/$(basename ${_BAK_SRC_DIR}).bak$(get_bak_index $_BAK_SRC_DIR $_BAK_DEST_PARENT)"
if [ $_BAK_SET_DEST == 'YES' ]; then
    if ! [ -d $_BAK_DEST_PARENT ]; then
        if [ $_BAK_CREATE_DESTDIR == 'YES' ]; then
            mkdir -p $_BAK_DEST_PARENT
        else
            echo "Error: dest directory not exist!"
            how_to_use 3
        fi
    fi
fi
if [ $_BAK_SET_SRC == 'YES' ]; then
    ! [ -d $_BAK_SRC_DIR ] && echo "Error: src directory not exist!" && how_to_use 3
fi

if [ $_BAK_SET_SRC == 'YES' ] || [ $_BAK_SET_DEST == 'YES' ]; then
    echo "SRC=$_BAK_SRC_DIR" > "$home_conf"
    echo "DEST=$_BAK_DEST_PARENT" >> "$home_conf"
    check_state
fi

if [ $_BAK_LIST == 'YES' ]; then
    _LIST_INFO="Current configuration:\n
    CONF:\t\t$_BAK_CONF\n
    SRC_DIR:\t$_BAK_SRC_DIR\n
    DEST_DIR:\t$_BAK_DEST_PARENT
    "
    echo -e $_LIST_INFO
    exit 0
fi

# real stuff
case $ACTION in
    backup)
        mkdir $_BAK_DEST_DIR
        cp -r -u $_BAK_SRC_DIR/* $_BAK_DEST_DIR/
        # attach extra info
        echo "TIME=\"$(date)\"" > "$_BAK_DEST_DIR/.hbackup_meta"
        [ $_BAK_SET_MSG == 'YES' ] && echo "MSG=\"$_BAK_MSG\"" >> "$_BAK_DEST_DIR/.hbackup_meta"
        ;;
    restore)
        printf "> From backups in\n> $_BAK_DEST_PARENT to\n> $_BAK_SRC_DIR:\n[Backup List]\n"
        baks=`get_bak_files $_BAK_SRC_DIR $_BAK_DEST_PARENT`
        get_string_seg "$baks" out_string

        if [ $_BAK_FORCE == 'YES' ]; then
            cp -rf -u "$_BAK_DEST_PARENT/$out_string" $_BAK_SRC_DIR/
        elif [ $_BAK_INTERACTIVE == 'YES' ]; then
            cp -r -i "$_BAK_DEST_PARENT/$out_string" $_BAK_SRC_DIR/
        else
            cp -r -u "$_BAK_DEST_PARENT/$out_string" $_BAK_SRC_DIR/
        fi
        ;;
esac
