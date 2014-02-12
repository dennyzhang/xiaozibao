#!/bin/bash -e
##-------------------------------------------------------------------
## File : utility.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2013-12-29>
## Updated: Time-stamp: <2014-02-12 12:49:00>
##-------------------------------------------------------------------
source /etc/profile # TODO
function log()
{
    local msg=${1?}
    echo -ne "\n"`date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
}

function exit_error()
{
    local msg=${1?}
    log "Error: $msg"; exit -1
}

function ensure_variable_isset() {
    var=${1}
    message=${2?"parameter name should be given"}
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
        data=$(echo "$data" | sed "s/\'/\\\\\"/g")
    else
        data=$(echo "$data" | sed "s/'/\\\\\"/g")
    fi;
    if [ "$header" = "" ]; then
        command="curl -d \"$data\" \"$url\""
    else
        command="curl $header -d \"$data\" \"$url\""
    fi;
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

function update_cfg() {
    cfg_file=${1?}
    key=${2?}
    value=${3?}
    if grep "$key=" $cfg_file ; then
        # We don't use sed here, because of various sed compatible issues
        # across macOS, Centos and ubuntu
        grep -v "$key=" $cfg_file > $cfg_file.tmp && mv $cfg_file.tmp $cfg_file
    fi

    echo "$key=$value" >> $cfg_file

}

function install_pip ()
{
    package=${1?}
    echo "pip install package $package"
    (pip freeze | grep $package) || sudo pip install selenium
}

function yum_install ()
{
    package=${1?}
    echo "yum install package $package"
    (rpm -qa | grep $package) || sudo yum install $package
}

XTRACE=$(set +o | grep xtrace)
set -o errexit
set -o xtrace

# Restore xtrace
$XTRACE
## File : utility.sh ends
