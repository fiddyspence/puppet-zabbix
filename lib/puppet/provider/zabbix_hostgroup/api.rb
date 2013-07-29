require 'rubygems'
require 'zabbixapi'
Puppet::Type.type(:zabbix_hostgroup).provide(:api) do

  confine  :kernel => 'linux'

  def exists?
    @property_hash[:ensure] == :present
  end

  def self.instances
# {"groupid"=>"5", "name"=>"Discovered hosts", "internal"=>"1"}
    instances = []
    moo = ZabbixApi.connect( :url => 'http://localhost/zabbix/api_jsonrpc.php', :user => 'Admin', :password => 'zabbix')
    foo = moo.hostgroups.get(:id => 0)
    foo.each do |hostgroup|
       instances << new(:name => hostgroup['name'], :internal => hostgroup['internal'], :groupid => hostgroup['groupid'], :ensure => :present)
    end
    instances
  end

  def self.prefetch(hostgroup)
    instances.each do |prov|
      if pkg = hostgroup[prov.name]
        pkg.provider = prov
      end
    end
  end

  def create
    moo = ZabbixApi.connect( :url => 'http://localhost/zabbix/api_jsonrpc.php', :user => 'Admin', :password => 'zabbix')
    moo.hostgroups.create(:name => @resource[:name])
  end

  def internal
    @property_hash[:internal]
  end

  def groupid
    @property_hash[:groupid]
  end

end
