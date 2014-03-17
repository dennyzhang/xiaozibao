#!/bin/bash -e
##-------------------------------------------------------------------
## File : tests.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-01-11>
## Updated: Time-stamp: <2014-03-17 15:31:05>
##-------------------------------------------------------------------
. $XZB_HOME/cmd/utility.sh

request_url_get "http://127.0.0.1:9180/api_list_posts_in_topic?topic=idea_startup&start_num=0&count=10" -I
request_url_get "http://127.0.0.1:9180/api_get_post?id=603b7839ca91880485b9895789291e25" -I
request_url_get "http://127.0.0.1:9180/api_list_posts_in_topic?topic=idea_startup&start_num=0&count=10&voteup=0" -I
request_url_get "http://127.0.0.1:9180/api_list_topic" -I
request_url_get "http://127.0.0.1:9181/list_topic?start_num=0&count=10&topic=algorithm&voteup=0&votedown=0" -I

# request_url_get http://127.0.0.1:9180/api_list_user_post?userid=denny
# request_url_get http://127.0.0.1:9180/api_list_user_post?userid=denny&date=2013-01-24

request_url_post http://127.0.0.1:9180/api_feedback_post "uid=denny&postid=25b83bb7702ad180532a8d7824f41d16&category=algorithm&comment=somecomment"
request_url_post http://127.0.0.1:9180/api_feedback_post "uid=denny&postid=25b83bb7702ad180532a8d7824f41d16&category=algorithm&comment=tag voteup"
## File : tests.sh ends
