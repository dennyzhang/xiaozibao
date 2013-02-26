#!/bin/bash
##-------------------------------------------------------------------
## @copyright 2013
## File : xzb_update_all.sh
## Author : filebat <markfilebat@126.com>
## Description : Install crontab to automatically update users' post
## --
## Created : <2013-02-01>
## Updated: Time-stamp: <2013-02-24 21:27:23>
##-------------------------------------------------------------------

# Sample crontab configuration
# 0 22,2,6,10,15 * * * /home/repository/xiaozibao/code/tool/xzb_update_users.sh
. $(dirname $0)/utility_xzb.sh

BIN_NAME="$(basename $0 .sh)"
VERSION=0.1

function refresh_all() {
    refreshportal=${1?}
    date=${2?}
    user_list=${3?}    
    date=$(echo $date |sed 's/-//g')

    cd $XZB_HOME; git pull && \
        $XZB_HOME/code/tool/xzb_update_category.sh && \
        mysql -uuser_2013 -pilovechina xzb < $XZB_HOME/code/tool/update_db.sql && \
        xzb_update_users.sh --force --date $date --userlist "$user_list"
}

help()
{
    cat <<EOF
Usage: ${BIN_NAME}.sh [OPTION]

Sample: sudo ${BIN_NAME}.sh
Sample: sudo ${BIN_NAME}.sh --userlist "denny liki" --date "2013-02-01" --refreshportal

${BIN_NAME} is a shell script to update all users html

Optional arguments:
 --userlist            username list. Default is all users in mysql
 --date                which date to generate. Default value is current date
 --refreshportal       whether refreshportal
 -h, --help            display this help
 -v, --version         print version information
EOF
 exit 0
}

ensure_variable_isset
ensure_is_root

#default value
date=$(date +%Y-%m-%d)
refreshportal="f"
ARGS=`getopt -a -o hv -l userlist:,date:,version,refreshportal,help -- "$@"`
[ $? -ne 0 ] && help
eval set -- "${ARGS}"

while true
do
    case "$1" in
        --refreshportal)
            refreshportal="t"
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
        --userlist)
            userlist="$2"
            shift
            ;;
        --date)
            date="$2"
            shift
            ;;
        --)
            shift
            break
            ;;
    esac
    shift
done

if [ -z "$userlist" ]; then
    userlist=$(userlist_in_db)
fi

refresh_all "$refreshportal" "$date" "$userlist"
if [ $? -ne 0 ]; then
    log "========== update_all for date($date) fail ============="
    exit 1
else
    log "update_all for date($date) succeed"
fi;

## File : xzb_update_all.sh ends
