#!/bin/bash -e
##-------------------------------------------------------------------
## File : tests.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-01-11>
## Updated: Time-stamp: <2014-03-16 13:47:50>
##-------------------------------------------------------------------
. $XZB_HOME/cmd/utility.sh

request_url_get "http://127.0.0.1:9181/show_post?id=25b83bb7702ad180532a8d7824f41d16" -I
request_url_get "http://127.0.0.1:9181/list_topic?start_num=0&count=10&topic=idea_startup" -I
## File : tests.sh ends
