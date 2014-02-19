#!/bin/bash -e
##-------------------------------------------------------------------
## File : upgrade.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-01-11>
## Updated: Time-stamp: <2014-02-18 22:27:04>
##-------------------------------------------------------------------
. utility.sh
source /etc/profile # TODO
ensure_variable_isset "$XZB_HOME" # TODO remove this code duplication

log "install html directories"
[ -d $XZB_HOME/html_data/ ] || mkdir -p $XZB_HOME/html_data
cp -r $XZB_HOME/code/show_article/smarty_html/templates/resource $XZB_HOME/html_data

log "install scripts to \$PATH"
(cd ../tool && sudo make install)
## File : upgrade.sh ends
