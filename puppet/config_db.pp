import "setting.pp"

class config_db {
  $db_name = "xzb"
  exec {
    createdb:
      command=>"mysql -u${mysql_root_username} ${mysql_root_password} < $XZB_HOME/files/install_db.sql",
      user=>"root",
      unless => "mysql -u${mysql_root_username} ${mysql_root_password} -e \"show databases\" mysql | grep $db_name",
      path => "/bin:/sbin:/usr/bin:/usr/sbin:/bin:/usr/local/bin/"
  }
}
