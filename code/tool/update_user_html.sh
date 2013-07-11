#!/bin/bash
##-------------------------------------------------------------------
## @copyright 2013
## File : update_user_html.sh
## Author : filebat <markfilebat@126.com>
## Description : Update posts info to mysql
## --
## Created : <2013-01-31>
## Updated: Time-stamp: <2013-07-11 17:46:01>
##-------------------------------------------------------------------
. $(dirname $0)/utility_xzb.sh

BIN_NAME="$(basename $0 .sh)"
VERSION=0.1

function update_user_html() {
    user_dir=${1?"user website directory is required"}
    userid=${2?"userid is required"}
    date=${3?"date is required"}
    index_html="$user_dir/$(echo $date | tr -d -).html"
    if [ -f "$index_html" ] && [ -z "$force_build" ]; then
        log "[$BIN_NAME.sh] $index_html exists, skip the following generating work."
        log "[$BIN_NAME.sh] To enforce re-build, please use --force option."
        exit 0
    fi

    # copy resource file
    /bin/cp -r $XZB_HOME/code/show_article/smarty_html/templates/resource $user_dir

    # update main page
    python_script="import jinja_html; jinja_html.generate_list_user_post(\"$userid\", \"$date\", \"$index_html\")"

    command="(cd $XZB_HOME/code/show_article/smarty_html; python -c '${python_script}')"
    eval $command
    if [ $? -ne 0 ]; then
        log "[$BIN_NAME.sh] Generate $index_html failed."
        exit 1
    else
        log "[$BIN_NAME.sh] Generate $index_html is done."
    fi

    # update posts page
    python_script="import jinja_html; jinja_html.generate_user_all_posts(\"$userid\", \"$date\", \"$user_dir\")"
    command="(cd $XZB_HOME/code/show_article/smarty_html; python -c '${python_script}')"
    eval $command
    if [ $? -ne 0 ]; then
        log "[$BIN_NAME.sh] Generate html files of user posts failed."
        exit 1
    else
        log "[$BIN_NAME.sh] Generate html files of user posts is done."
    fi
}

help()
{
cat <<EOF
Usage: ${BIN_NAME}.sh [OPTION]

Sample: sudo ${BIN_NAME}.sh --user denny --date 2013-01-24 --vhostdir /home/wwwroot/denny.youwen.im
+----------------------+   +--------------------+   +------------------------------+
|                      |   |                    |   |                              |
| generate index.php   +---+ generate main page +---+ generate html files of posts |
|                      |   |                    |   |                              |
+----------------------+   +--------------------+   +------------------------------+

${BIN_NAME} is a shell script to generate a user's html files for a given date

Mandatory arguments:
  --user                   username
  --date                   date
  --vhostdir               root directory for the vhost

Optional arguments:
  --force                  force to rebuild html files, even if it exist
  -h, --help               display this help
  -v, --version            output version information
EOF
    exit 0
}

ensure_variable_isset
ensure_is_root

ARGS=`getopt -a -o hv -l user:,date:,vhostdir:,force,version,help -- "$@"`
[ $? -ne 0 ] && help
eval set -- "${ARGS}"

while true
do
    case "$1" in
        --force)
            force_build="t"
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
        --user)
            userid="$2"
            shift
            ;;
        --date)
            date="$2"
            shift
            ;;
        --vhostdir)
            vhostdir="$2"
            shift
            ;;
        --)
            shift
            break
            ;;
    esac
    shift
done

if [ -z "$vhostdir" ]; then
    echo "vhostdir is a mandatory option"
    help
    exit 1
fi

if [ -z "$userid" ]; then
    echo "userid is a mandatory option"
    help
    exit 1
fi

if [ -z "$date" ]; then
    echo "date is a mandatory option"
    help
    exit 1
fi

update_user_html "$vhostdir" $userid $date

## File : update_user_html.sh ends
