#!/bin/bash -e
##-------------------------------------------------------------------
## File : utility.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2013-12-29>
## Updated: Time-stamp: <2014-01-11 11:18:36>
##-------------------------------------------------------------------
function log()
{
    local msg=${1?}
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
}

function exit_error()
{
    local msg=${1?}
    log "Error: $msg"; exit -1
}

function ensure_variable_isset() {
    var=${1}
    message=${2:-"parameter name should be given"}
    # TODO support sudo, without source
    if [ -z "$var" ]; then
        echo "Error: Certain variable($message) is not set"
        exit 1
    fi
}

function ensure_is_root() {
    # Make sure only root can run our script
    if [[ $EUID -ne 0 ]]; then
        echo "Error: This script must be run as root." 1>&2
        exit 1
    fi
}

function request_url_post() {
    url=${1?}
    data=${2?}
    header=${3:-""}
    if [ `uname` == "Darwin" ]; then
        data=$(echo "$data" | sed "s/\'/\\\\\"\/g")
    else
        data=$(echo "$data" | sed "s/\'/\\\\\"\/g")
    fi;
    command="curl $header -d \"$data\" \"$url\""
    echo -e "\n$command"
    eval "$command"
    if [ $? -ne 0 ]; then
        echo "Error: fail to run $command"; exit -1
    fi
}

function request_url_get() {
    url=${1?}
    header=${2:-""}
    command="curl $header \"$url\""
    echo -e "\n$command"
    eval "$command"
    if [ $? -ne 0 ]; then
        echo "Error: fail to run $command"; exit -1
    fi
}
XTRACE=$(set +o | grep xtrace)
set -o errexit
set -o xtrace

# Restore xtrace
$XTRACE
## File : utility.sh ends
