#!/bin/bash
##-------------------------------------------------------------------
## @copyright 2013
## File : utility_xzb.sh
## Author : filebat <markfilebat@126.com>
## Description : Update posts info to mysql
## --
## Created : <2013-01-31>
## Updated: Time-stamp: <2014-03-16 13:48:42>
##-------------------------------------------------------------------
DB_HOST="127.0.0.1"
DB_USERNAME="user_2013"
DB_PWD="ilovechina"
DB_NAME="xzb"
FLASK_SERVER_PORT="9180"

source /etc/profile
function log()
{
    local msg=${1?}
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
}

function ensure_variable_isset() {
    # TODO support sudo, without source
    if [ -z "$XZB_HOME" ]; then
        echo "Error: Global variable(XZB_HOME) is not set, which is normally github's checkout path."
        echo "       Please make necessary changes to /etc/profile, then reboot."
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

function userlist_in_db() {
    echo $(mysql -uuser_2013 -pilovechina xzb -e "select userid as '' from users;")
}

function category_in_fs() {
    echo $(ls -lt $XZB_HOME/webcrawler_data | grep ^'d' | awk -F':' '{print $2}' | awk -F' ' '{print $2}')
}
## File : utility_xzb.sh ends
