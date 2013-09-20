# This is the base zabbix class

class zabbix (
  $managerepo = false,
  $mysql_config_hash = {},
  $postgresql_config_hash = {},
  $server = false,
  $managedb = false,
  $dbserver = '',
) {

  package { 'zabbixapi':
    ensure   => present,
    provider => 'gem',
  }
#  if $managerepo {
#    require zabbix::repo
#  }

  if $server {
    class { 'zabbix::server':
      managedb => $::zabbix::managedb,
      dbserver => $::zabbix::dbserver,
      mysql_config_hash => $::zabbix::mysql_config_hash,
    }
  }
}
