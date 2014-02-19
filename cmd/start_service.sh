#!/bin/bash -e
##-------------------------------------------------------------------
## File : start_service.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2013-12-29>
## Updated: Time-stamp: <2014-02-18 23:08:07>
##-------------------------------------------------------------------
. utility.sh
source /etc/profile # TODO
function start_rabbitmq ()
{
    log "start rabbitmq"
    sudo lsof -i tcp:55672 || nohup sudo rabbitmq-server start &
}

function start_mysqld ()
{
    log "start mysqld"
    sudo ps -ef | grep mysqld || service mysqld start
}

function start_snaker ()
{
    log "start snaker"
    sudo snake_workerd ping || sudo snake_workerd start
}

function start_webserver ()
{
    log "start webserver"

    (cd $XZB_HOME/code/show_article/webserver && sudo lsof -i tcp:9080 || nohup python ./server.py &)
}

function smarty_html ()
{
    log "smarty html"

    (cd $XZB_HOME/code/show_article/smarty_html && sudo lsof -i tcp:9081 || nohup python ./server.py &)
}

start_rabbitmq
start_mysqld
start_snaker
start_webserver
smarty_html
## File : start_service.sh ends
