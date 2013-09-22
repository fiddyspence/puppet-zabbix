This is the zabbix module

It uses https://github.com/vadv/zabbixapi to talk to the JSONRpc API presented by Zabbix, but I am going to change that soon.

It is currently only partially featured - it will install a zabbix server on EL, create hosts and hostgroups.

The Zabbix API is, I apologise for this, not awesome.

The base class will install a zabbix server, using either MySQL or Postgresql as the backend

Example usage for MySQL:

    node 'zabbixmysql' inherits default {
      class { 'zabbix': server => true, managedb => true, dbserver => 'mysql' }
      Zabbix_host <<| |>>
    }

Example usage for Postgres:

    node 'zabbixpg' inherits default {
      class { 'zabbix': server => true, managedb => true, dbserver => 'postgresql' }
      Zabbix_host <<| |>>
    }
    
    
    node default {
      # Export a host definition, to be imported by the zabbix server
      @@zabbix_host { $::fqdn:
        ensure     => 'present',
        groups     => ['Linux servers','foogroup'],
        interfaces => [ { type => 1, main => 1, ip => $::ipaddress, dns => $::fqdn, port => 10050, useip => 1 } ],
      }
      
    }

License
-------
Apache 2.

Contact
-------
cspence@puppetlabs.com

