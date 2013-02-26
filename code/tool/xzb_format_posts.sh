#!/bin/bash
##-------------------------------------------------------------------
## @copyright 2013
## File : xzb_format_posts.sh
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-01-31>
## Updated: Time-stamp: <2013-02-19 22:49:40>
##-------------------------------------------------------------------
. $(dirname $0)/utility_xzb.sh

BIN_NAME="$(basename $0 .sh)"
VERSION=0.1

function check_lengthy_post() {
    log "Check lengthy posts"
    cd $XZB_HOME/data; find . -type f -and -name "*.data" -and -size +4k -exec ls -lth "{}" \; | grep -v done
}

function check_short_post() {
    log "Check too short posts"
    # find . -type f -and -name "*.data" -and -size -1024c -exec rm -rf "{}" \;
    cd $XZB_HOME/data; find . -type f -and -name "*.data" -and -size -1024c -exec ls -lth "{}" \; | grep -v done
}

function auto_repair() {
    log "auto repair posts"
    # $XZB_HOME/code/tool/xzb_update_category.sh -c "health lifehack joke"
}

function check_data() {
    log "check quality of posts"
    check_short_post
    check_lengthy_post
    # python -c "import fs_check; fs_check.fs_check()"
    # python -c "import db_check; db_check.db_check()"
    # python -c "import post_check; post_check.post_check()"
}

help()
{
cat <<EOF
Usage: ${BIN_NAME}.sh [OPTION]

Sample: sudo ${BIN_NAME}.sh

+-----------------+   +----------------------+     +----------------------------+
|                 |   |                      |     |                            |
| posts' quality  +---+ meta data validation +-----+  db/filesystem consistency |
|                 |   |                      |     |                            |
+-----------------+   +----------------------+     +----------------------------+

${BIN_NAME} is a shell script to make sure all data is valid

Optional arguments:
  -h, --help               display this help
  -v, --version            output version information
EOF
    exit 0
}

ensure_variable_isset

ARGS=`getopt -a -o vh -l version,help -- "$@"`
[ $? -ne 0 ] && help
eval set -- "${ARGS}"

while true
do
    case "$1" in
        -v|--version)
            echo "${BIN_NAME} version ${VERSION}"
            shift
            exit 0
            ;;
        -h|--help)
            help
            shift
            exit 0
            ;;
        --)
            shift
            break
            ;;
    esac
    shift
done

check_data
## File : xzb_format_post.sh ends
