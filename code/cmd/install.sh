#!/bin/bash -e
##-------------------------------------------------------------------
## File : install.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-01-11>
## Updated: Time-stamp: <2014-01-11 13:05:16>
##-------------------------------------------------------------------
. utility.sh

ensure_variable_isset "$XZB_HOME"

log "install html directories"
[ -d $XZB_HOME/html_data/ ] || mkdir -p $XZB_HOME/html_data
cp -r $XZB_HOME/code/tool/smarty_html/templates/resource $XZB_HOME/html_data

log "install scripts to \$PATH"
(cd ../tool && sudo make install)
## File : install.sh ends
