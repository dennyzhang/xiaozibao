#!/bin/bash -e
##-------------------------------------------------------------------
## File : tests.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-01-11>
## Updated: Time-stamp: <2014-03-19 16:09:48>
##-------------------------------------------------------------------
. $XZB_HOME/cmd/utility.sh

request_url_get "http://127.0.0.1:9181/show_post?id=1afb02292810e52cbc4a5facb530c2c8" -I
request_url_get "http://127.0.0.1:9181/list_topic?start_num=0&count=10&topic=idea_startup" -I
request_url_get "http://127.0.0.1:9180/api_list_posts_in_topic?topic=algorithm&start_num=0&count=1000&voteup=0&votedown=0" -I
request_url_get "http://127.0.0.1:9180/api_list_posts_in_topic?topic=concept&start_num=0&count=1000&voteup=0&votedown=0" -I
request_url_get "http://127.0.0.1:9180/api_list_posts_in_topic?topic=product&start_num=0&count=1000&voteup=0&votedown=0" -I
request_url_get "http://127.0.0.1:9180/api_list_posts_in_topic?topic=linux&start_num=0&count=1000&voteup=0&votedown=0" -I
request_url_get "http://127.0.0.1:9180/api_list_posts_in_topic?topic=network&start_num=0&count=1000&voteup=0&votedown=0" -I
## File : tests.sh ends
