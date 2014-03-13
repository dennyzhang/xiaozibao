#!/bin/bash -e
##-------------------------------------------------------------------
## File : installation.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-01-11>
## Updated: Time-stamp: <2014-03-12 18:45:34>
##-------------------------------------------------------------------
. utility.sh
# ensure_variable_isset "$XZB_HOME" # TODO

function install_package ()
{
    log "install package"

    # yum_install mysql-server
    # yum_install mysql
    # yum_install MySQL-python
    # yum_install python-pip
    # yum_install golang
    # yum_install erlang
    # yum_install rabbitmq-server

    pip_install markdown
    pip_install flask
    pip_install MySQL-python
    pip_install pika
    pip_install Sqlalchemy

    # install snake
    which snake_workerd || (cd $XZB_HOME/code/webcrawl_article/snake_worker && rm -rf rel/snake_worker && make release && sudo make install)

    # ln -s /usr/local/bin/snake_workerd /usr/sbin/
}

function init_db ()
{
    log "init_db"
    # TODO connect to mysql and execute below sql scripts
    # xiaozibao/puppet/files/install_db.sql
}

function update_profile ()
{
    cfg_file="/etc/profile"
    log "update $cfg_file to configure global environments"
    update_cfg $cfg_file "XZB_HOME" "$(dirname `pwd`)"

    update_cfg $cfg_file "GOPATH" "${XZB_HOME}/code/webcrawl_article/webcrawler"

    source /etc/profile
}

function setup_ios_env ()
{
    log "setup ios env in OSX for iPhone development "
    # TODO follow instruction of xiaozibao/code/show_article/ios_client/README.md
}

update_profile
setup_ios_env
install_package

log "install html directories"
[ -d $XZB_HOME/html_data/ ] || mkdir -p $XZB_HOME/html_data
cp -r $XZB_HOME/code/show_article/smarty_html/templates/resource $XZB_HOME/html_data

log "install scripts to \$PATH"
(cd $XZB_HOME/code/tool && sudo make install)

log "install python libraries"
pip_install selenium

init_db
## File : installation.sh ends
