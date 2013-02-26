#!/bin/bash
##-------------------------------------------------------------------
## @copyright 2013
## File : markdown_to_html.sh
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-02-02>
## Updated: Time-stamp: <2013-02-05 10:18:28>
##-------------------------------------------------------------------
source /etc/profile # TODO betterway
. $XZB_HOME/code/tool/utility_xzb.sh

ensure_variable_isset
IFS=$(echo -en "\n\b")
for file in `find $XZB_HOME -name "*.md"`
do
    html_file="${file%.md}.html"
    (echo "<meta charset='utf-8'>"; markdown "$file") > "$html_file"
    log "generate $html_file"
done
IFS=$SAVEIFS
## File : markdown_to_html.sh ends