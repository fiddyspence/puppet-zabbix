class zabbix::mysql {

  $packages = ['zabbix-server-mysql','zabbix-web-mysql']
  anchor { 'zabbix::db::begin': } ->
  package { $packages:
    ensure => present,
  } ->
  class { 'mysql::server':
    config_hash => $::zabbix::server::mysql_config_hash,
  } -> 
  mysql::db { $::zabbix::server::zabbixdatabase:
    user     => $::zabbix::server::zabbixdbuser,
    password => $::zabbix::server::zabbixdbpassword,
    host     => 'localhost',
    grant    => ['all'],
  } ->
  file { '/var/lib/zabbix':
    ensure => directory,
  } ->
  file { '/var/lib/zabbix/import.sh':
    ensure => file,
    source => 'puppet:///modules/zabbix/import.sh',
    mode   => '0755',
  } ~>
  exec { 'create_zabbix_databases':
    command     => '/var/lib/zabbix/import.sh',
    require     => Mysql::Db['zabbix'],
    creates     => "/usr/share/doc/zabbix-server-mysql-${::zabbix_version}/create/.done",
    timeout     => 600,
  }
  anchor { 'zabbix::db::end': }
}
