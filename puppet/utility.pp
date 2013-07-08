define check_variable_not_empty($var) {
  if $var=="" {
    fail("err: mandatory value of $name is empty, which is probably misconfigured.")
  }
}

define update_option_in_ini ($key, $value) {
  # update a config file of ini format for a given keymeter.
  # If the keymeter is not found, append one line.
  exec {"update_ini_cfg":
    onlyif => "test `grep \"${key}\\+=\\+${value}\" $name | wc -l` -eq 0",
    command => "grep \"${key}\\+=\" ${name} && sed -i 's/${key}\\+=.*/${key}=${value}/' ${name} || (cat ${name}; echo \"${key}=${value}\") | tee ${name}",
    # verbose output for such a complicated operation
    logoutput => true,
    path => "/bin:/sbin:/usr/bin:/usr/sbin:/bin"
  }
}
