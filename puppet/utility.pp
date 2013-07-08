define check_variable_not_empty($var) {
  if $var=="" {
    fail("err: mandatory value of $name is empty, which is probably misconfigured.")
  }
}
