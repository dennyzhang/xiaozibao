#!/bin/bash -e
##-------------------------------------------------------------------
## File : tests.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-01-11>
## Updated: Time-stamp: <2014-03-19 22:39:15>
##-------------------------------------------------------------------
. $XZB_HOME/cmd/utility.sh

request_url_get "http://127.0.0.1:9181/show_post?id=1afb02292810e52cbc4a5facb530c2c8" -I
request_url_get "http://127.0.0.1:9181/list_topic?start_num=0&count=10&topic=cloud" -I
request_url_get "http://127.0.0.1:9181/list_topic?start_num=0&count=1000&topic=algorithm&voteup=0&votedown=0" -I
request_url_get "http://127.0.0.1:9181/list_topic?start_num=0&count=1000&topic=cloud&voteup=0&votedown=0" -I
request_url_get "http://127.0.0.1:9181/list_topic?start_num=0&count=1000&topic=concept&voteup=0&votedown=0" -I
request_url_get "http://127.0.0.1:9181/list_topic?start_num=0&count=1000&topic=linux&voteup=0&votedown=0" -I
request_url_get "http://127.0.0.1:9181/list_topic?start_num=0&count=1000&topic=security&voteup=0&votedown=0" -I
request_url_get "http://127.0.0.1:9181/list_topic?start_num=0&count=1000&topic=network&voteup=0&votedown=0" -I
request_url_get "http://127.0.0.1:9181/list_topic?start_num=0&count=1000&topic=product&voteup=0&votedown=0" -I
## File : tests.sh ends
