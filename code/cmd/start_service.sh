#!/bin/bash -e
##-------------------------------------------------------------------
## File : start_service.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2013-12-29>
## Updated: Time-stamp: <2014-01-11 11:12:19>
##-------------------------------------------------------------------
. utility.sh
function start_rabbitmq ()
{
    log "start rabbitmq"
    sudo lsof -i tcp:55672 || nohup sudo rabbitmq-server start &
}

function start_snaker ()
{
    log "start snaker"
    sudo snake_workerd ping || sudo snake_workerd start
}

function start_webserver ()
{
    log "start webserver"

    (cd $XZB_HOME/code/show_article/webserver && ./start.sh)
}

ensure_variable_isset "$XZB_HOME"

start_rabbitmq
start_snaker
start_webserver

## File : start_service.sh ends
