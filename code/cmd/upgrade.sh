#!/bin/bash -e
##-------------------------------------------------------------------
## File : upgrade.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-01-11>
## Updated: Time-stamp: <2014-01-11 12:31:38>
##-------------------------------------------------------------------
. utility.sh
ensure_is_root

log "install scripts to \$PATH"
(cd ../tool && make install)
## File : upgrade.sh ends
