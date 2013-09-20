class zabbix::postgresql {

  $packages = ['zabbix-server-pgsql','zabbix-web-pgsql']
  anchor { 'zabbix::db::begin': } ->
  package { $packages:
    ensure => present,
  } ->
  class { '::postgresql':
    server_package_name => 'postgresql92-server',
    client_package_name => 'postgresql92',
    service_name => 'postgresql-9.2',
    manage_package_repo => true,
    run_initdb => true,
    bindir => '/usr/pgsql-9.2/bin',
    datadir => '/var/lib/pgsql/9.2/data/',
    confdir => '/var/lib/pgsql/9.2/data/',
  } ->
  class { 'postgresql::server':
    config_hash => $::zabbix::server::postgresql_config_hash,
  } -> 
  
  postgresql::db { $::zabbix::server::zabbixdatabase:
    user      => $::zabbix::server::zabbixdbuser,
    password => postgresql_password($::zabbix::server::zabbixdbuser, $::zabbix::server::zabbixdbpassword)
  } ->
  file { "${::puppet_vardir}/zabbix":
    ensure => directory,
  } ->
  file { "/var/lib/zabbix/import.sh":
    ensure => file,
    source => 'puppet:///modules/zabbix/import_pgsql.sh',
    mode   => '0755',
  } ~>
  exec { 'create_zabbix_databases':
    command => "/var/lib/zabbix/import.sh",
    require => Postgresql::Db[$::zabbix::server::zabbixdatabase],
    creates => "/usr/share/doc/zabbix-server-mysql-${::zabbix_version}/create/.done",
    timeout => 600,
    user    => $::zabbix::server::zabbixdbuser,
    group   => $::zabbix::server::zabbixdbuser,
  } ->
  anchor { 'zabbix::db::end': }

  postgresql::pg_hba_rule { 'allow local access for zabbix user':
    description => 'allow local access for zabbix user',
    type => 'local',
    database => $::zabbix::server::zabbixdatabase,
    user => $::zabbix::server::zabbixdbuser,
    auth_method => 'md5',
    before => Exec['create_zabbix_databases'],
  }
  postgresql::pg_hba_rule { 'allow local access for root user':
    description => 'allow local access for zabbix user',
    type => 'local',
    database => $::zabbix::server::zabbixdatabase,
    user => 'root',
    auth_method => 'ident',
    before => Exec['create_zabbix_databases'],
  }

}
