#!/bin/bash -e
##-------------------------------------------------------------------
## File : uninstallation.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-01-11>
## Updated: Time-stamp: <2014-03-10 13:29:56>
##-------------------------------------------------------------------
. utility.sh
ensure_variable_isset "$XZB_HOME"

log "clean up rabbitmq channels"
# TODO should only remove channels leading with "snake_worker-shell"
sudo rabbitmqctl stop_app && sudo rabbitmqctl reset && sudo rabbitmqctl start_app
## File : uninstallation.sh ends
