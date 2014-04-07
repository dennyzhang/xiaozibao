#!/bin/bash -e
##-------------------------------------------------------------------
## File : tests.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-01-11>
## Updated: Time-stamp: <2014-04-07 19:36:14>
##-------------------------------------------------------------------
. $XZB_HOME/cmd/utility.sh

request_url_get "http://127.0.0.1:9180/api_list_posts_in_topic?topic=concept&start_num=0&count=10" -I
request_url_get "http://127.0.0.1:9180/api_get_post?postid=1afb02292810e52cbc4a5facb530c2c8" -I
request_url_get "http://127.0.0.1:9180/api_list_posts_in_topic?topic=concept&start_num=0&count=10&voteup=0" -I
request_url_get "http://127.0.0.1:9180/api_list_topic" -I
request_url_get "http://127.0.0.1:9181/list_topic?start_num=0&count=10&topic=algorithm&voteup=0&votedown=0" -I

request_url_get "http://127.0.0.1:9180/apple_privacy"
request_url_post "http://127.0.0.1:9180/apple_privacy" "key=test"

# request_url_get http://127.0.0.1:9180/api_list_user_post?userid=testuser
# request_url_get http://127.0.0.1:9180/api_list_user_post?userid=testuser&date=2013-01-24

request_url_post http://127.0.0.1:9180/api_feedback_post "uid=testuser&postid=25b83bb7702ad180532a8d7824f41d16&category=algorithm&comment=tag envoteup"
## File : tests.sh ends
