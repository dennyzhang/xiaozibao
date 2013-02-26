#!/bin/bash
##-------------------------------------------------------------------
## @copyright 2013
## File : xzb_fetch_url.sh
## Author : filebat <markfilebat@126.com>
## Description : Install crontab to automatically update users' post
## --
## Created : <2013-02-01>
## Updated: Time-stamp: <2013-02-24 21:26:57>
##-------------------------------------------------------------------

# Sample crontab configuration
# 0 22,2,6,10,15 * * * /home/repository/xiaozibao/code/tool/xzb_update_users.sh
. $(dirname $0)/utility_xzb.sh

BIN_NAME="$(basename $0 .sh)"
VERSION=0.1

function fetch_url() {
    url=${1?}
    dst_dir=${2?}
    export GOPATH=$XZB_HOME/code/webcrawler
    cd $GOPATH
    go run ./src/main.go --fetch_url $url --dst_dir $dst_dir
}

help()
{
    cat <<EOF
Usage: ${BIN_NAME}.sh [OPTION]

Sample: sudo ${BIN_NAME}.sh --fetch_url http://haowenz.com/a/bl/2013/2608.html --dst_dir webcrawler_raw_haowenz

${BIN_NAME} is a shell script to fetch url

Mandatory arguments:
 --url                 url to fetch
 --dst_dir             location to store the webpage

Optional arguments:
 --refreshportal       whether refreshportal
 -h, --help            display this help
 -v, --version         print version information
EOF
 exit 0
}

ensure_variable_isset

#default value
ARGS=`getopt -a -o hv -l fetch_url:,version,dst_dir:,help -- "$@"`
[ $? -ne 0 ] && help
eval set -- "${ARGS}"

while true
do
    case "$1" in
        --fetch_url)
            fetch_url="$2"
            shift
            ;;
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
        --dst_dir)
            dst_dir="$2"
            shift
            ;;
        --)
            shift
            break
            ;;
    esac
    shift
done

if [ -z "$fetch_url" ]; then
    log "=== ERROR: fetch_url is mandatory, try -h for more ====\n"
    exit 1
fi

if [ -z "$dst_dir" ]; then
    log "=== ERROR: dst_dir is mandatory, try -h for more ====\n"
    exit 1
fi

fetch_url $fetch_url $dst_dir
if [ $? -ne 0 ]; then
    log "========== fetch_url for url($fetch_url) fail ============="
    exit 1
else
    log "fetch_url for url($fetch_url) succeed"
fi;

## File : xzb_fetch_url.sh ends
