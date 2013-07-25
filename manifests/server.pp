class zabbix::server (
  $mysql_config_hash = {},
  $manage_mysql,
  $zabbixmysqlpassword = 'foopassword',
  $php_timezone = 'Europe/London',
){

  if $manage_mysql {

    class { 'mysql::server':
      config_hash => $::zabbix::server::mysql_config_hash,
      before      => Package[$::zabbix::server_packages],
    }

    mysql::db { 'zabbix':
      user     => 'zabbix',
      password => $::zabbix::server::zabbixmysqlpassword,
      host     => 'localhost',
      grant    => ['all'],
    }

  }
  package { $::zabbix::server_packages:
    ensure => present,
  } ->
  file { "${::puppet_vardir}/zabbix":
    ensure => directory,
  } ->
  file { "${::puppet_vardir}/zabbix/import.sh":
    ensure => file,
    source => 'puppet:///modules/zabbix/import.sh',
    mode   => '0755',
  } ~>
  exec { 'create_zabbix_databases':
    command     => "${::puppet_vardir}/zabbix/import.sh",
    require     => Mysql::Db['zabbix'],
    creates     => "/usr/share/doc/zabbix-server-mysql-${::zabbix_version}/create/.done",
    timeout     => 600,
  }

  service { 'zabbix-server':
    ensure => running,
    enable => true,
    require => Exec['create_zabbix_databases'],
  }

  Ini_setting {
    path    => '/etc/zabbix/zabbix_server.conf',
    section => '',
    ensure  => present,
    notify  => Service['zabbix-server'],
    require => Package[$::zabbix::server_packages],
  }
  ini_setting { "zabbix_db":
    setting => 'DBName',
    value   => 'zabbix',
  }
  ini_setting { "zabbix_dbhost":
    setting => 'DBHost',
    value   => 'localhost',
  }
  ini_setting { "zabbix_dbuser":
    setting => 'DBUser',
    value   => 'zabbix',
  }
  ini_setting { "zabbix_dbpassword":
    setting => 'DBPassword',
    value   => $zabbixmysqlpassword,
  }
  
  file { '/etc/httpd/conf.d/zabbix.conf':
    ensure => file,
    content => template('zabbix/zabbix.conf.erb'),
    require => Package[$::zabbix::server_packages],
  } ~>
  service { 'httpd':
    ensure => running,
    enable => true,
    subscribe => Package[$::zabbix::server_packages],
  }

  file { '/etc/zabbix/web/zabbix.conf.php':
    ensure  => file,
    content => template('zabbix/zabbix.conf.php.erb'),
    require => Package[$::zabbix::server_packages],
  }
}
