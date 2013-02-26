#!/bin/bash
##-------------------------------------------------------------------
## @copyright 2013
## File : inotify_change.sh
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-02-01>
## Updated: Time-stamp: <2013-02-10 17:13:26>
##-------------------------------------------------------------------

while inotifywait $XZB_HOME/; do $XZB_HOME/code/tool/xzb_update_category.sh; mysql -uuser_2013 -pilovechina xzb < $XZB_HOME/code/tool/update_db.sql ;done;

## File : inotify_change.sh ends
