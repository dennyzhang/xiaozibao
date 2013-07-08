class install_python_package {
  package {
    [
     "flask", "pika", "markdown", "jinja", "mysql-python",
     ]:
       provider => pip,
       ensure => installed;
  }
}

class install_mac_package {
  package {
    [
     "pip"
     ]:
       provider => mac,
       ensure => installed;
  }
}
