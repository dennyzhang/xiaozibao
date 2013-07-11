#!/bin/bash
##-------------------------------------------------------------------
## @copyright 2013
## File : weibo_god_reply.sh
## Author : filebat <markfilebat@126.com>
## Description : 
## --
## Created : <2013-02-01>
## Updated: Time-stamp: <2013-07-11 16:14:53>
##-------------------------------------------------------------------

# Sample crontab configuration
. $(dirname $0)/utility_xzb.sh

BIN_NAME="$(basename $0 .sh)"
VERSION=0.1

MAX_WORKER=2
function parse_god_reply() {
    dir=${1?}
    export GOPATH=$XZB_HOME/code/filter_article/postwasher
    cd $GOPATH

    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    i=0
    for file in `find $XZB_HOME/$dir -name '*_raw*' -prune -o -name '*.data'  -mtime -3 -print`
    do
        short_file=`basename $file`
        count=$(ps -ef | grep 'go run' | wc -l)
        if [ $count -lt $MAX_WORKER ]; then
            echo "[$count] run background task"
            go run ./src/main.go --wash_file "$1/$short_file" >> $XZB_HOME/webcrawler_data/result.txt &
        else
            echo "[$count] run task"
            go run ./src/main.go --wash_file "$1/$short_file" >> $XZB_HOME/webcrawler_data/result.txt
        fi;
    done
    IFS=$SAVEIFS
}

# parse_god_reply "webcrawler_data/webcrawler_haowenz"

> $XZB_HOME/webcrawler_data/result.txt
parse_god_reply "webcrawler_data/jeffz_weibo"
parse_god_reply "webcrawler_data/jacky_weibo"
parse_god_reply "webcrawler_data/easy_weibo"
parse_god_reply "webcrawler_data/colin_weibo"
parse_god_reply "webcrawler_data/sophia_weibo"
parse_god_reply "webcrawler_data/allen_weibo"
## File : xzb_fetch_url.sh ends
