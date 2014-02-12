#!/bin/bash -e
##-------------------------------------------------------------------
## File : installation.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-01-11>
## Updated: Time-stamp: <2014-02-12 12:50:33>
##-------------------------------------------------------------------
. utility.sh

ensure_variable_isset "$XZB_HOME"

function install_package ()
{
    log "install package"

    # install golang

    yum_install erlang

}

function update_profile ()
{
    cfg_file="/etc/profile"
    log "update $cfg_file to configure global environments"
    update_cfg $cfg_file "XZB_HOME" "$(dirname `pwd`)"
}

install_package
update_profile

log "install html directories"
[ -d $XZB_HOME/html_data/ ] || mkdir -p $XZB_HOME/html_data
cp -r $XZB_HOME/code/show_article/smarty_html/templates/resource $XZB_HOME/html_data

log "install scripts to \$PATH"
(cd ../tool && sudo make install)

log "install python libraries"
install_pip selenium

## File : installation.sh ends
