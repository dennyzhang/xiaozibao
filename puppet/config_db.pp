import "setting.pp"

class config_db {
  $db_name = "xzb"
  exec {
    createdb:
      command=>"mysql --default-character-set utf8 -u${mysql_root_username} -p${mysql_root_password} < $XZB_HOME/puppet/files/install_db.sql",
      user=>"root",
      unless => "mysql --default-character-set utf8 -u${mysql_root_username} -p${mysql_root_password} -e \"show databases\" mysql | grep $db_name",
      path => "/bin:/sbin:/usr/bin:/usr/sbin:/bin:/usr/local/bin/"
  }

  file {
    "/usr/":
      ensure => directory,
      mode => 0755, owner => $os_root_username, group=> $os_root_groupname;
    "/usr/local/":
      ensure => directory,
      require => File["/usr/"],
      mode => 0755, owner => $os_root_username, group=> $os_root_groupname;
    "/usr/local/xiaozibao":
      ensure => directory,
      require => File["/usr/local"],
      mode => 0755, owner => $os_root_username, group=> $os_root_groupname;
    "/usr/local/xiaozibao/db_schema.sql":
      require => File["/usr/local/xiaozibao"],
      subscribe => Exec["createdb"],
      content => template("$XZB_HOME/puppet/files/db_schema.sql"),
      mode => 0755, owner => $os_root_username, group=> $os_root_groupname;
  }
  
  exec {
    updateschema:
      command=>"mysql -u${mysql_root_username} -p${mysql_root_password} < $XZB_HOME/puppet/files/db_schema.sql || mv /usr/local/xiaozibao/db_schema.sql",
      user=>"root",
      subscribe => File["/usr/local/xiaozibao/db_schema.sql"],
      path => "/bin:/sbin:/usr/bin:/usr/sbin:/bin:/usr/local/bin/",
      refreshonly => true;
  }
}
