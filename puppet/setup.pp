import "install_package.pp"
import "setting.pp"

################  enforce common rules ###############
# parameter check to detect configuration problem
check_variable_not_empty { "mysql_root_username": var => $mysql_root_username}
check_variable_not_empty { "mysql_root_password": var => $mysql_root_password}
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
