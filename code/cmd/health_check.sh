#!/bin/bash -e
##-------------------------------------------------------------------
## File : health_check.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-01-11>
## Updated: Time-stamp: <2014-01-11 11:18:45>
##-------------------------------------------------------------------
. utility.sh

log "Check service running"
sudo lsof -i tcp:55672 || exit_error "Rabbitmq is not running"
sudo snake_workerd ping || exit_error "snake_workerd is not running"

## File : health_check.sh ends
