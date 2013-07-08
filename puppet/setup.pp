import "install_package.pp"
import "setting.pp"
import "update_files.pp"
import "config_db.pp"
################  enforce common rules ###############
# parameter check to detect configuration problem
check_variable_not_empty { "os_root_username": var => $os_root_username}
check_variable_not_empty { "os_root_groupname": var => $os_root_groupname}
check_variable_not_empty { "HOME": var => $HOME}
check_variable_not_empty { "XZB_HOME": var => $XZB_HOME}
include config_os
include config_db
######################################################

################  enforce conditional rules ##########
case $operatingsystem {
  'Darwin':{
    include install_python_package
  }
  'Ubuntu':{
    # TODO
    include install_python_package
  }
  default: { err("\$operatingsystem of ${fqdn} is not supported.") }
}
######################################################
