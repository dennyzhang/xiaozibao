define check_variable_not_empty($var) {
  if $var=="" {
    fail("err: mandatory value of $name is empty, which is probably misconfigured.")
  }
}

define update_option_in_ini ($key, $value, $extra_str="") {
  # update a config file of ini format for a given keymeter.
  # If the keymeter is not found, append one line.
  exec {"update_ini_cfg_$name":
    onlyif => "test `grep \"${key}=\\\"${value}\\\"\" $name | wc -l` -eq 0",
    command => "grep \"${key}=\" ${name} && sed -ie 's/.*${key}=.*//' ${name} || echo \"\n${extra_str}${key}=\\\"${value}\\\"\" | tee -a ${name}",
    # verbose output for such a complicated operation
    logoutput => true,
    path => "/bin:/sbin:/usr/bin:/usr/sbin:/bin:/usr/local/bin/"
  }
}
