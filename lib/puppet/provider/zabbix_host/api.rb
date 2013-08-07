# we need to monkey patch the 0.6.0 version of the zabbixapi to return interfaces

require 'zabbixapi'
require File.join(Gem.loaded_specs['zabbixapi'].full_gem_path, 'lib', 'zabbixapi', '2.0', 'basic', 'basic_alias.rb')
class ZabbixApi
  class Hosts < Basic
    def get_full_data(data)
      log "[DEBUG] Call get_full_data with parametrs: #{data.inspect}"

      @client.api_request(
        :method => "#{method_name}.get",
        :params => {
          :filter => {
            indentify.to_sym => data[indentify.to_sym]
          },
          :selectInterfaces => 'extend',
          :selectGroups => 'extend',
          :output => "extend",
          :limitSelects => 10,
        }
      )
    end
  end
end
Puppet::Type.type(:zabbix_host).provide(:api) do

  confine  :kernel => 'linux'

  def exists?
    @property_hash[:ensure] == :present
  end

#[{"groups"=>[{"groupid"=>"1", "name"=>"Templates", "internal"=>"0"}, {"groupid"=>"2", "name"=>"Linux servers", "internal"=>"0"}, {"groupid"=>"4", "name"=>"Zabbix servers", "internal"=>"0"}, {"groupid"=>"5", "name"=>"Discovered hosts", "internal"=>"1"}, {"groupid"=>"11", "name"=>"foogroup", "internal"=>"0"}, {"groupid"=>"13", "name"=>"mmmmfoogroup", "internal"=>"0"}], "interfaces"=>{"2"=>{"interfaceid"=>"2", "hostid"=>"10085", "main"=>"1", "type"=>"1", "useip"=>"1", "ip"=>"192.168.0.20", "dns"=>"puppet1.spence.org.uk.local", "port"=>"10050"}, "7"=>{"interfaceid"=>"7", "hostid"=>"10085", "main"=>"0", "type"=>"1", "useip"=>"1", "ip"=>"127.0.0.1", "dns"=>"", "port"=>"10050"}}, "maintenances"=>[], "hostid"=>"10085", "proxy_hostid"=>"0", "host"=>"puppet1.spence.org.uk.local", "status"=>"0", "disable_until"=>"0", "error"=>"", "available"=>"1", "errors_from"=>"0", "lastaccess"=>"0", "ipmi_authtype"=>"0", "ipmi_privilege"=>"2", "ipmi_username"=>"", "ipmi_password"=>"", "ipmi_disable_until"=>"0", "ipmi_available"=>"0", "snmp_disable_until"=>"0", "snmp_available"=>"0", "maintenanceid"=>"0", "maintenance_status"=>"0", "maintenance_type"=>"0", "maintenance_from"=>"0", "ipmi_errors_from"=>"0", "snmp_errors_from"=>"0", "ipmi_error"=>"", "snmp_error"=>"", "jmx_disable_until"=>"0", "jmx_available"=>"0", "jmx_errors_from"=>"0", "jmx_error"=>"", "name"=>"puppet1.spence.org.uk.local"}]

  def self.instances
    instances = []
    moo = ZabbixApi.connect( :url => 'http://localhost/zabbix/api_jsonrpc.php', :user => 'Admin', :password => 'zabbix')
    foo = moo.hosts.get(:id => 0)
    foo.each do |host|
       groups=[]
       host['groups'].each do |group|
         groups << group['name']
       end
#       interfaces=[]
#       host['interfaces'].each do |interface|
#         
#       end

       instances << new(:name => host['host'], :groups => groups, :ensure => :present, :dnsname => host['host'], :interfaces => host['interfaces'])
    end
    instances
  end

  def self.prefetch(host)
    instances.each do |prov|
      if pkg = host[prov.name]
        pkg.provider = prov
      end
    end
  end

  def create
    moo = ZabbixApi.connect( :url => 'http://localhost/zabbix/api_jsonrpc.php', :user => 'Admin', :password => 'zabbix')
    moo.hosts.create(:name => @resource[:name])
  end

  def internal
    @property_hash[:internal]
  end

  def groupid
    @property_hash[:groupid]
  end
  def ip
    '127.0.0.1'
  end

  def groups
    @property_hash[:groups]
  end
  def dnsname
    @property_hash[:dnsname]
  end
  def interfaces 
    @property_hash[:interfaces]
  end
end
