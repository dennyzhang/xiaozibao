#!/bin/bash -e
##-------------------------------------------------------------------
## File : installation.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-01-11>
## Updated: Time-stamp: <2014-01-14 17:37:00>
##-------------------------------------------------------------------
. utility.sh

ensure_variable_isset "$XZB_HOME"

function install_pip ()
{
    package=${1?}
    (pip freeze | grep $package) || sudo pip install selenium
}

log "install html directories"
[ -d $XZB_HOME/html_data/ ] || mkdir -p $XZB_HOME/html_data
cp -r $XZB_HOME/code/show_article/smarty_html/templates/resource $XZB_HOME/html_data

log "install scripts to \$PATH"
(cd ../tool && sudo make install)

log "install python libraries"
install_pip selenium

## File : installation.sh ends
