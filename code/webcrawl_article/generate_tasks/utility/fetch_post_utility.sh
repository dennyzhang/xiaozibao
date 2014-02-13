#!/bin/bash
##-------------------------------------------------------------------
## @copyright 2013
## File : fetch_post_utility.sh
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-02-01>
## Updated: Time-stamp: <2014-02-13 14:46:32>
##-------------------------------------------------------------------
. /usr/bin/utility_xzb.sh

SLEEP_SECONDS=3

######################### platform websites ############################
function fetch_page() {
    dst_dir=${1?}
    url_link=${2?}
    id_list=${3:-""}
    if [[ -z "$id_list" ]]; then
        for url in `generate_command "$2" | grep ^http`; do
            command="xzb_mq_tool.py insert xzb_fetch_url.sh -d $dst_dir -f $url"
            $command
        done;
    else
        lists=($id_list)
        for id in ${lists[*]}; do
            for url in `generate_command "$2$id" | grep ^http`; do
                command="xzb_mq_tool.py insert xzb_fetch_url.sh -d $dst_dir -f $url"
                $command
            done;
        done;
    fi;
    sleep $SLEEP_SECONDS
}

function generate_seq() {
    start_id=${1?}
    end_id=${2?}
    val=""
    for((i=$start_id; i<= $end_id; i++)); do { val="$val $i" ;}; done
    echo "$val"
}

function generate_command() {
    generator_url=${1?}
    export GOPATH=$XZB_HOME/code/webcrawl_article/webcrawler
    cd $GOPATH
    go run ./src/main.go --fetch_url $generator_url --shall_generator
}
########################################################################
## File : fetch_post_utility.sh ends
