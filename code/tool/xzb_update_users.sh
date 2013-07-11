#!/bin/bash
##-------------------------------------------------------------------
## @copyright 2013
## File : xzb_update_users.sh
## Author : filebat <markfilebat@126.com>
## Description : Install crontab to automatically update users' post
## --
## Created : <2013-02-01>
## Updated: Time-stamp: <2013-07-11 17:45:25>
##-------------------------------------------------------------------

# Sample crontab configuration
# 0 22,2,6,10,15 * * * /home/repository/xiaozibao/code/tool/xzb_update_users.sh
. $(dirname $0)/utility_xzb.sh

BIN_NAME="$(basename $0 .sh)"
VERSION=0.1

function refresh_portal() {
    domain=${1?}
    date=${2?}
    date=$(echo $date |sed 's/-//g')
    user_list=${3?}
    lists=($user_list)
    for user in ${lists[*]}; do
        index_php="/home/wwwroot/$user.$domain/index.php"
        sudo sed -ie "s/^\$htmlFile =.*/\$htmlFile = file(\"$date.html\");/g" "$index_php"
    done;
}

function update_all_user() {
    domain=${1?}
    date=${2?}
    user_list=${3?}
    force_build=${4?}
    lists=($user_list)
    for user in ${lists[*]}; do
        log "[$BIN_NAME.sh] $user for the day of $date."
        if [ -z "$force_build" ]; then
            $XZB_HOME/code/tool/update_user_html.sh --user $user --vhostdir /home/wwwroot/$user.$domain --date $date;
        else
            $XZB_HOME/code/tool/update_user_html.sh --user $user --vhostdir /home/wwwroot/$user.$domain --date $date --force;
        fi;
    done;
}

help()
{
    cat <<EOF
Usage: ${BIN_NAME}.sh [OPTION]

Sample: sudo ${BIN_NAME}.sh
Sample: sudo ${BIN_NAME}.sh --userlist "denny liki" --domain "localhost" --date "2013-02-01" --force --refreshportal

${BIN_NAME} is a shell script to update all users html

Optional arguments:
 --userlist            username list. Default is all users in mysql
 --date                which date to generate. Default value is current date
 --domain              domain name. Default value is youwen.im
 --refreshportal       whether refreshportal
 --force               force to rebuild html files, even if it exist
 -h, --help            display this help
 -v, --version         print version information
EOF
 exit 0
}

ensure_variable_isset
ensure_is_root

#default value
date=$(date +%Y-%m-%d)
domain="youwen.im"
ARGS=`getopt -a -o hv -l userlist:,date:,domain:,force,version,refreshportal,help -- "$@"`
[ $? -ne 0 ] && help
eval set -- "${ARGS}"

while true
do
    case "$1" in
        --force)
            force_build="t"
            ;;
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
        --domain)
            domain="$2"
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

update_all_user "$domain" "$date" "$userlist" "$force_build"
if [ $? -ne 0 ]; then
    log "========== update_all_users for domain($domain), date($date), force_build($force_build) fail ============="
    exit 1
else
    log "update_all_users for domain($domain), date($date), force_build($force_build) succeed"
fi;

if [ -n "$refreshportal" ]; then
    refresh_portal "$domain" "$date" "$userlist"
    if [ $? -ne 0 ]; then
        log "============== refresh portal for domain($domain), date($date) fail ==================="
        exit 1
    else
        log "refresh portal for domain($domain), date($date) succeed"
    fi;
fi;

## File : xzb_update_users.sh ends
