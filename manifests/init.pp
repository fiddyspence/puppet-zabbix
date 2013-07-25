class zabbix (
  $managerepo = false,
  $server_packages = ['zabbix-server-mysql','zabbix-web-mysql'],
  $mysql_config_hash = {},
  $server = false,
  $manage_mysql = false,
) {

  package { 'zabbixapi':
    ensure => present,
    provider => 'gem',
  }
  if $managerepo {
    require zabbix::repo
  }

  if $server {
    class { 'zabbix::server':
      manage_mysql => $::zabbix::manage_mysql,
      mysql_config_hash => $::zabbix::mysql_config_hash,
    }
  }
}
