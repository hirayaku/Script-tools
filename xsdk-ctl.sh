#!/bin/bash

# TODO: add options like -L, -P to indicate whether to follow the soft link or not
help_text="
xsdk-ctl usage:
\nxsdk-ctl [-h|l|f] [-d [-c] <dest_dir>] [-s <src_dir>]
\n         [-p <project_rootdir>] [store|restore|build]
\n
\n  -h      print help text
\n
\n  -l      print current configurations
\n
\n  -f      force overwrite when restoring
\n
\n  -i      interactive mode; prompt before overwriting
\n
\n  -b <backup_dir_parent>
\n          set destination directory to backup the files to.
\n          if not given by the user, default directory will be the result of \`\$(wpd)/../\`
\n
\n  -bc <dest_dir>
\n          create the directory if not exist
\n
\n  -s <src_dir>
\n          set original directory to copy the files from.
\n          if not given by the user, default directory will be the child dir
\n          ended with \`.bak\` in the dest_dir.
\n
\n  -p <project_rootdir>
\n          set the sdk project top-level directory. It is usually named xxx.sdk
\n          Default value is empty string (build will fail in this case)
\n
\n  store   backup the contents in <src_dir> into <dest_dir>
\n
\n  restore restore the contents from <dest_dir> into <dest_dir>
\n
\n  build   build the project given by the <project_rootdir>.
"
help_text_refined="
xsdk-ctl usage:
\nxsdk-ctl [-h|l|f|i] [-b|-bc <backup_dir>] [-s <src_dir>]
\n         [-p <project_rootdir>] [store|restore|build]
"
info="Control the source files for Xilinx SDK to avoid the buggy IDE"
version="0.1"
author="hirayaku"
default_rootdir='/d/Documents/src/Verilog/ZYBO/'    # default rootdir for FPGA projects

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
    printf "Select one to restore from: "
    while true; do
        read choice
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

num_args=$#
script_name=$0
if [ $num_args -eq 0 ]; then
    how_to_use 0
fi

# Default states
_XSDK_CONF_DIR=".xsdk_conf"
_XSDK_SRC_DIR=`pwd`
_XSDK_SRC_DIR_BASE=`basename $_XSDK_SRC_DIR`
_XSDK_DEST_DIR=$(realpath $_XSDK_SRC_DIR/..)
_XSDK_DEST_DIR_BASE=''
_XSDK_PROJ_DIR=''
_XSDK_HELP='NO'
_XSDK_LIST='NO'
_XSDK_FORCE='NO'
_XSDK_INTERACTIVE='NO'
_XSDK_SET_DEST='NO'
_XSDK_CREATE_DESTDIR='NO'
_XSDK_SET_SRC='NO'
_XSDK_SET_PROJ='NO'
_XSDK_ACTION=''
_OPT_STATE=''
mkdir -p "$_XSDK_CONF_DIR"
check_state

# get options
for opt in "$@"; do
    # when the previous opt is -d|s|p, later opt should be the directory path
    case "$_OPT_STATE" in
        set_dest*)
            _XSDK_DEST_DIR=`realpath $opt`
            _OPT_STATE=''
            shift
            continue
            ;;
        set_src*)
            _XSDK_SRC_DIR=`realpath $opt`
            _OPT_STATE=''
            shift
            continue
            ;;
        set_proj*)
            _XSDK_PROJ_DIR=`realpath $opt`
            _OPT_STAET=''
            shift
            continue
            ;;
        *)
            ;;
    esac

    case $opt in
        -h*)
            _XSDK_HELP='YES'
            shift
            ;;
        -l*)
            _XSDK_LIST='YES'
            shift
            ;;
        -f*)
            _XSDK_FORCE='YES'
            shift
            ;;
        -i*)
            _XSDK_INTERACTIVE='YES'
            shift
            ;;
        -b)
            _XSDK_SET_DEST='YES'
            _OPT_STATE='set_dest'
            shift
            ;;
        -c)
            _XSDK_CREATE_DESTDIR='YES'
            shift
            ;;
        -bc|-cb)
            _XSDK_SET_DEST='YES'
            _XSDK_CREATE_DESTDIR='YES'
            _OPT_STATE='set_dest'
            shift
            ;;
        -s*)
            _XSDK_SET_SRC='YES'
            _OPT_STATE='set_src'
            shift
            ;;
        -p*)
            _XSDK_SET_PROJ='YES'
            _OPT_STATE='set_proj'
            shift
            ;;
        store|restore|build)
            if [ -z $ACTION ]; then
                ACTION=$opt
            else
                echo "Error: Do not assign more than one action"
                how_to_use 2
            fi
            shift
            ;;
        # not matched by any above
        *)
            echo "Error: Unknown option: $opt"
            how_to_use 1
    esac
done

if [ $_XSDK_HELP == 'YES' ]; then
    echo -e $help_text
    exit 0
fi

# check if appointed directories exist
_XSDK_DEST_PARENT=$_XSDK_DEST_DIR
_XSDK_DEST_DIR="$_XSDK_DEST_PARENT/$(basename ${_XSDK_SRC_DIR}).bak$(get_bak_index $_XSDK_SRC_DIR $_XSDK_DEST_PARENT)"
if [ $_XSDK_SET_DEST == 'YES' ]; then
    if ! [ -d $_XSDK_DEST_PARENT ]; then
        if [ $_XSDK_CREATE_DESTDIR == 'YES' ]; then
            mkdir -p $_XSDK_DEST_PARENT
        else
            echo "Error: dest directory not exist!"
            how_to_use 3
        fi
    fi
fi

if [ $_XSDK_SET_SRC == 'YES' ]; then
    ! [ -d $_XSDK_SRC_DIR ] && echo "Error: src directory not exist!" && how_to_use 3
fi

if [ $_XSDK_SET_PROJ == 'YES' ]; then
    ! [ -d $_XSDK_PROJ_DIR ] && echo "Error: proj directory not exist!" && how_to_use 3
fi

if [ $_XSDK_LIST == 'YES' ]; then
    _LIST_INFO="Current configuration:\n
    CONF_DIR:\t$_XSDK_CONF_DIR\n
    SRC_DIR:\t$_XSDK_SRC_DIR\n
    DEST_DIR:\t$_XSDK_DEST_DIR\n
    PROJ_DIR:\t$_XSDK_PROJ_DIR
    "
    echo -e $_LIST_INFO
    exit 0
fi

# real stuff
case $ACTION in
    store)
        mkdir $_XSDK_DEST_DIR
        cp -r -u $_XSDK_SRC_DIR/* $_XSDK_DEST_DIR/
        ;;
    restore)
        printf "From $_XSDK_DEST_PARENT:\n"
        baks=`get_bak_files $_XSDK_SRC_DIR $_XSDK_DEST_PARENT`
        get_string_seg "$baks" out_string

        if [ $_XSDK_FORCE == 'YES' ]; then
            cp -rf -u "$_XSDK_DEST_PARENT/$out_string" $_XSDK_SRC_DIR/
        elif [ $_XSDK_INTERACTIVE == 'YES' ]; then
            cp -r -i "$_XSDK_DEST_PARENT/$out_string" $_XSDK_SRC_DIR/
        else
            cp -r -u "$_XSDK_DEST_PARENT/$out_string" $_XSDK_SRC_DIR/
        fi
        ;;
    build)
        # nothing here yet...
        # still need to look into the datasheet to know how to build
        ;;
esac
