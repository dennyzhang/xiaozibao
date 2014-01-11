#!/bin/bash -e
##-------------------------------------------------------------------
## File : start_service.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2013-12-29>
## Updated: Time-stamp: <2014-01-10 17:41:35>
##-------------------------------------------------------------------
. utility.sh
# XTRACE=$(set +o | grep xtrace)
# set -o errexit
# set -o xtrace

function start_rabbitmq ()
{
    log "start rabbitmq"
    sudo lsof -i tcp:55672 || nohup sudo rabbitmq-server start &
}

start_rabbitmq

ensure_variable_isset "$XZB_HOME"
log "start webserver"

(cd $XZB_HOME/code/show_article/webserver && ./start.sh)


# Restore xtrace
# $XTRACE

## File : start_service.sh ends
