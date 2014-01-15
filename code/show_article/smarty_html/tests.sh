#!/bin/bash -e
##-------------------------------------------------------------------
## File : tests.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-01-11>
## Updated: Time-stamp: <2014-01-15 11:36:56>
##-------------------------------------------------------------------
. $XZB_HOME/code/cmd/utility.sh

request_url_get http://127.0.0.1:9081/show_post?id=0fa410a29c294cf498c768b0cebc99c0
request_url_get http://127.0.0.1:9081/list_topic?start_num=0&count=10&topic=idea_startup
## File : tests.sh ends
