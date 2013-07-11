import "utility.pp"

class config_os {
  file {
    # workaround to config python's defaultencoding as utf-8
    # http://gpiot.com/python-set-character-encoding-to-utf-8-for-deploy-cms/
    "/usr/lib/python2.7/site.py":
      mode => 0644, owner => $os_root_username, group=> $os_root_groupname,
      content => template("$XZB_HOME/puppet/templates/site.py");
  }
  update_option_in_ini{ "/etc/profile":
    key => "XZB_HOME", value => $XZB_HOME, extra_str => "export ",
  }
  update_option_in_ini{ "$HOME/.bashrc":
    key => "XZB_HOME", value => $XZB_HOME, extra_str => "export ",
  }
  exec {
    "install_xzb_tools":
      command => "cd $XZB_HOME/code/tool/; make install",
      path => "/bin:/sbin:/usr/bin:/usr/sbin:/bin:/usr/local/bin/"
  }

  case $operatingsystem {
    'Darwin':{
      exec {
        "link_md5":
          command => "which md5 && ln -s `which md5` /usr/bin/md5sum",
          user=>"root",
          unless => "test -f /usr/bin/md5sum",
          path => "/bin:/sbin:/usr/bin:/usr/sbin:/bin:/usr/local/bin/"
      }
    }
  }
}
