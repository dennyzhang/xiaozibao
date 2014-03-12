#!/bin/bash -e
##-------------------------------------------------------------------
## File : tests.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-01-11>
## Updated: Time-stamp: <2014-03-11 22:23:59>
##-------------------------------------------------------------------
. $XZB_HOME/cmd/utility.sh

#request_url_get http://127.0.0.1:9080/api_get_post?id=0fa410a29c294cf498c768b0cebc99c0
request_url_get "http://127.0.0.1:9080/api_list_topic?topic=idea_startup&start_num=0&count=10" -I

# request_url_get http://127.0.0.1:9080/api_list_user_post?userid=denny
# request_url_get http://127.0.0.1:9080/api_list_user_post?userid=denny&date=2013-01-24

request_url_post http://127.0.0.1:9080/api_feedback_post "uid=denny&postid=25b83bb7702ad180532a8d7824f41d16&category=algorithm&comment=somecomment"
## File : tests.sh ends
