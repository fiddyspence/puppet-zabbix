class zabbix::credentials (
  $username = 'Admin',
  $password = 'zabbix',
  $zabbixhost = '127.0.0.1'
) {

  file { '/root/.zabbix':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    content => template('zabbix/dotzabbix.erb'),
  }

}
