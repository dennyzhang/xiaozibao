service {
  rabbitmq-server:
    ensure => running,
    enable => true,
    hasstatus => true,
    require => Package["rabbitmq-server"];
}
