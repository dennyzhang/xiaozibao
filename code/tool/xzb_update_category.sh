#!/bin/bash
##-------------------------------------------------------------------
## @copyright 2013
## File : xzb_update_category.sh
## Author : filebat <markfilebat@126.com>
## Description : Update posts info to mysql
## --
## Created : <2013-01-31>
## Updated: Time-stamp: <2013-07-11 17:45:42>
##-------------------------------------------------------------------
. $(dirname $0)/utility_xzb.sh

BIN_NAME="$(basename $0 .sh)"
VERSION=0.1

function update_category_list() {
    category_list=${1?}
    lists=($category_list)
    for category_name in ${lists[*]}; do
        log "[$BIN_NAME.sh] Generate metadata files for $XZB_HOME/webcrawler_data/$category_name"
        update_meta_skeleton "$XZB_HOME/webcrawler_data/$category_name"

        log "[$BIN_NAME.sh] Generate sql file for $directory."
        sql_output=$(generate_category_sql "$XZB_HOME/webcrawler_data/$category_name")
        if [ $? -ne 0 ]; then
            log "[$BIN_NAME.sh] Generate sql file failed."
            exit 1
        else
            sql_file="/tmp/data.sql"
            echo "$sql_output" > $sql_file
            command="mysql -uuser_2013 -pilovechina xzb < /tmp/data.sql"
            echo "Import sql file($sql_file) to mysql: $command"
            eval $command
        fi;
    done;
}
# sample: sh ./post_sql_generation.sh /home/denny/backup/essential/Dropbox/private_data/xiaozibao/webcrawler_data/lifehack
function generate_category_sql() {
    directory=${1?"base web page directory is required for sql generation"}
    category=`basename $directory`
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    for file in `find $directory -name '*_raw*' -prune -o -name '*.data' -print`
    do
        short_file=`basename $file`
        title=${short_file%.data}
        md5=$(echo -n "$category/$title"| md5sum | awk -F' ' '{print $1}')
        sql="REPLACE INTO posts(id, category, title) VALUES (\"$md5\", \"$category\", \"$title\");"
        echo $sql
    done
    IFS=$SAVEIFS
}

function update_meta_skeleton() {
    directory=${1?"base web page directory is required for generating metadata file skeleton"}
    category=`basename $directory`
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    for file in `find $directory -name '*_raw*' -prune -o -name '*.data' -print`
    do
        short_file=`basename "$file"`
        title=${short_file%.data}
        md5=$(echo -n "$category/$title"| md5sum | awk -F' ' '{print $1}')
        sed -ie "s/^id:.*/id: $md5/" "$file"
    done
    IFS=$SAVEIFS
}

help()
{
cat <<EOF
Usage: ${BIN_NAME}.sh [OPTION]

Sample: sudo ${BIN_NAME}.sh -c "lifehack joke"

+-------------------------------+   +-----------------------------------+     +----------------------------+
|                               |   |                                   |     |                            |
| generate meta file if missing +---+ insert posts to mysql, if missing +-----+  update posts' id to mysql |
|                               |   |                                   |     |                            |
+-------------------------------+   +-----------------------------------+     +----------------------------+

${BIN_NAME} is a shell script to update maintain posts information to mysql.

Optional arguments:
  -c, --categorylist       category name, which is directory name under
                           $XZB_HOME/webcrawler_data, like lifehack, lifehack, etc.
                           Default value is all distinct category in posts table of mysql
  -h, --help               display this help
  -v, --version            output version information
EOF
    exit 0
}

ensure_variable_isset

if [ `uname` = "Darwin" ]; then
    ARGS=`getopt c:vh "$@"`
else
    ARGS=`getopt -a -o c:vh -l categorylist:,version,help -- "$@"`
fi;

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
        -c|--categorylist)
            category_list="$2"
            shift
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

if [ -z "$category_list" ]; then
    category_list=$(category_in_fs)
fi

ensure_is_root

update_category_list "$category_list"

## File : xzb_update_category.sh ends
