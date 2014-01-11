#!/bin/bash -e
##-------------------------------------------------------------------
## File : upgrade.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-01-11>
## Updated: Time-stamp: <2014-01-11 13:04:14>
##-------------------------------------------------------------------
. utility.sh

ensure_variable_isset "$XZB_HOME" # TODO remove this code duplication

log "install scripts to \$PATH"
(cd ../tool && sudo make install)
## File : upgrade.sh ends
