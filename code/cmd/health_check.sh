#!/bin/bash -e
##-------------------------------------------------------------------
## File : health_check.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-01-11>
## Updated: Time-stamp: <2014-01-11 11:24:03>
##-------------------------------------------------------------------
. utility.sh

snake_worker_logdir="/usr/local/xiaozibao/snake_worker/log"

log "Check service running"
sudo lsof -i tcp:55672 || exit_error "Rabbitmq is not running"
sudo snake_workerd ping || exit_error "snake_workerd is not running"
log "Check error in log files"
monitor_dir $snake_worker_logdir || exit_error "Error found in $snake_worker_logdir"
## File : health_check.sh ends
