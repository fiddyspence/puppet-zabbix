class zabbix::server (
  $mysql_config_hash = {},
  $managedb = false,
  $dbserver = '',
  $zabbixdbpassword = 'foopassword',
  $zabbixdbuser = 'zabbix',
  $zabbixdatabase = 'zabbix',
  $php_timezone = 'Europe/London',
  $zabbix_servername = $::hostname,
  $zabbixhost = 'localhost',
  $zabbixport = '10051',
){

  include zabbix::credentials
  if $managedb {
    unless $dbserver in ['mysql','postgresql'] {
      fail ("${::modulename}: You passed ${dbserver} to dbplatform, which is an illegal value - choose 'mysql' or 'postgresql'")
    }
  }
  if $managedb and $dbserver != '' {

    include "zabbix::${dbserver}"

  }
  user { 'zabbix':
    ensure => present,
    before => Exec['create_zabbix_databases'],
    home   => '/var/lib/zabbix',
    managehome => 'true',
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
    require => Anchor['zabbix::db::end'],
    notify  => Service['zabbix-server'],
  }
  ini_setting { "zabbix_db":
    setting => 'DBName',
    require => Anchor['zabbix::db::end'],
    value   => $zabbixdatabase,
  }
  ini_setting { "zabbix_dbhost":
    setting => 'DBHost',
    require => Anchor['zabbix::db::end'],
    value   => 'localhost',
  }
  ini_setting { "zabbix_dbuser":
    setting => 'DBUser',
    require => Anchor['zabbix::db::end'],
    value   => $zabbixdbuser,
  }
  ini_setting { "zabbix_dbpassword":
    setting => 'DBPassword',
    require => Anchor['zabbix::db::end'],
    value   => $zabbixdbpassword,
  }
  
  file { '/etc/httpd/conf.d/zabbix.conf':
    ensure => file,
    content => template('zabbix/zabbix.conf.erb'),
    require => Exec['create_zabbix_databases'],
  } ~>
  service { 'httpd':
    ensure => running,
    enable => true,
  }

  file { '/etc/zabbix/web/zabbix.conf.php':
    ensure  => file,
    content => template('zabbix/zabbix.conf.php.erb'),
    require => Exec['create_zabbix_databases'],
  }
}
