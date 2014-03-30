class zabbix::repo (
  $gpgkeypath = '/etc/pki/rpm-gpg/RPM-GPG-KEY-ZABBIX',
){

  anchor { 'zabbix::repo::start': }->

  yumrepo { 'zabbix':
    baseurl  => "http://repo.zabbix.com/zabbix/2.0/rhel/${::operatingsystemmajrelease}/\$basearch/",
    descr    => 'Zabbix Official Repository - $basearch',
    enabled  => '1',
    gpgcheck => '1',
    gpgkey   => "file://${zabbix::repo::gpgkeypath}",
  } ->

  yumrepo { 'zabbix-non-supported':
    baseurl  => "http://repo.zabbix.com/non-supported/rhel/${::operatingsystemmajrelease}/\$basearch/",
    descr    => 'Zabbix Official Repository non-supported - $basearch ',
    enabled  => '1',
    gpgcheck => '1',
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-ZABBIX',
  } -> 

  file { $zabbix::repo::gpgkeypath:
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/zabbix/RPM-GPG-KEY-ZABBIX',
  } ~>

  exec {  "import_zabbix_gpgkey":
    path      => '/bin:/usr/bin:/sbin:/usr/sbin',
    command   => "rpm --import ${zabbix::repo::gpgkeypath}",
    unless    => "rpm -q gpg-pubkey-$(echo $(gpg --throw-keyids < ${zabbix::repo::gpgkeypath}) | cut --characters=11-18 | tr '[A-Z]' '[a-z]')",
    logoutput => 'on_failure',
  } ->

  anchor { 'zabbix::repo::end': }


}
