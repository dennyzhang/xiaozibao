#!/bin/bash
##-------------------------------------------------------------------
## @copyright 2013
## File : weibo_god_reply.sh
## Author : filebat <markfilebat@126.com>
## Description : 
## --
## Created : <2013-02-01>
## Updated: Time-stamp: <2013-03-05 00:28:35>
##-------------------------------------------------------------------

# Sample crontab configuration
. $(dirname $0)/utility_xzb.sh

BIN_NAME="$(basename $0 .sh)"
VERSION=0.1

function parse_god_reply() {
    dir=${1?}
    export GOPATH=$XZB_HOME/code/postwasher
    cd $GOPATH

    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    for file in `find $XZB_HOME/$dir -name '*_raw*' -prune -o -name '*.data' -print`
    do
        short_file=`basename $file`
        go run ./src/main.go --wash_file "$1/$short_file"
    done
    IFS=$SAVEIFS
}

parse_god_reply "webcrawler_data/easy_weibo"
parse_god_reply "webcrawler_data/colin_weibo"
parse_god_reply "webcrawler_data/sophia_weibo"
parse_god_reply "webcrawler_data/allen_weibo"
## File : xzb_fetch_url.sh ends
