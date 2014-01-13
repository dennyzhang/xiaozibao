#!/bin/bash -e
##-------------------------------------------------------------------
## File : tests.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-01-11>
## Updated: Time-stamp: <2014-01-12 11:10:12>
##-------------------------------------------------------------------
. $XZB_HOME/code/cmd/utility.sh

request_url_get http://127.0.0.1:9081/show_post?id=0fa410a29c294cf498c768b0cebc99c0
request_url_get http://127.0.0.1:9081/list_topic?topic=idea_startup&start_num=0&count=10
## File : tests.sh ends
