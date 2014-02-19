#!/bin/bash -e
##-------------------------------------------------------------------
## File : installation.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-01-11>
## Updated: Time-stamp: <2014-02-18 22:26:38>
##-------------------------------------------------------------------
. utility.sh
source /etc/profile # TODO
# ensure_variable_isset "$XZB_HOME" # TODO

function install_package ()
{
    log "install package"

    # install golang

    # yum_install erlang

    # install snake
    which snake_workerd || (cd $XZB_HOME/code/webcrawl_article/snake_worker && rm -rf rel/snake_worker && make release && sudo make install)

    # ln -s /usr/local/bin/snake_workerd /usr/sbin/
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
(cd $XZB_HOME/code/tool && sudo make install)

log "install python libraries"
install_pip selenium

## File : installation.sh ends