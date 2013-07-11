#!/bin/bash
##-------------------------------------------------------------------
## @copyright 2013
## File : xzb_create_user.sh
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-02-02>
## Updated: Time-stamp: <2013-07-11 17:43:17>
##-------------------------------------------------------------------
. $(dirname $0)/utility_xzb.sh

BIN_NAME="$(basename $0 .sh)"
VERSION=0.1

function add_user() {
    domain=${1?}
    user_list=${2?}
    lists=($user_list)
    for name in ${lists[*]}; do
        cp /usr/local/nginx/conf/vhost/dennytest.$domain.conf /usr/local/nginx/conf/vhost/$name.$domain.conf && \
            command="s/dennytest/$name/g" && \
            mysql -uuser_2013 -pilovechina xzb -e "REPLACE INTO users(userid) VALUES ('$name');" && \
            sed -ie "$command" /usr/local/nginx/conf/vhost/$name.$domain.conf && \
            mkdir -p /home/wwwroot/$name.$domain;

            # update portal page
            vhostdir="/home/wwwroot/$name.$domain"
            index_html="$(date +%Y%m%d).html"
            cat > $vhostdir/index.php <<EOF
<?php
\$htmlFile = file("$index_html");
echo(implode('',\$htmlFile));
EOF
    done;

}

help()
{
    cat <<EOF
Usage: ${BIN_NAME}.sh [OPTION]

Sample: sudo ${BIN_NAME}.sh
Sample: sudo ${BIN_NAME}.sh --userlist "denny liki yao allen zan ning colin sophia sjembn haijun grace yuki clare jim" --domain "youwen.im"

${BIN_NAME} is a shell script to update all users html

Optional arguments:
 --userlist            username list. Default is all users in mysql
 --domain              domain name. Default value is youwen.im
 -h, --help            display this help
 -v, --version         print version information
EOF
 exit 0
}

ensure_variable_isset
ensure_is_root

#default value
domain="youwen.im"

ARGS=`getopt -a -o hv -l userlist:,domain:,version,help -- "$@"`
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
        --userlist)
            userlist="$2"
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
    echo "userlist is a mandatory option"
    help
    exit 1
fi

add_user $domain "$userlist" && \
    sudo /usr/local/nginx/sbin/nginx -s reload && \
    mysql -uuser_2013 -pilovechina xzb < $XZB_HOME/code/tool/update_db.sql
if [ $? -ne 0 ]; then
    log "================ create_user($user_list) fail =============="
    exit 1
else
    log "create_user($user_list) succeed"
fi;

## File : create_user.sh ends