#!/bin/bash
##-------------------------------------------------------------------
## @copyright 2013
## File : combine_joke.sh
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-02-01>
## Updated: Time-stamp: <2013-02-12 00:37:42>
##-------------------------------------------------------------------
. /usr/bin/utility_xzb.sh

function update_haowenz() {
    cd $XZB_HOME/data/joke/webcrawler_raw_haowenz
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    files=`find . -name '*_raw*' -prune -o -name '*.data' -print`
    lists=($files)

    for((i=0; i<${#lists[@]}; i++)); do {
            index=`expr $i / 4`
            cat "${lists[i]}" >> ./"test_$index.data"
        }; done

    IFS=$SAVEIFS
}

update_haowenz
## File : combine_joke.sh ends
