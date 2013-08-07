Puppet::Type.newtype(:zabbix_host) do
# [{"interfaces"=>{"2"=>{"interfaceid"=>"2", "hostid"=>"10085", "main"=>"1", "type"=>"1", "useip"=>"1", "ip"=>"192.168.0.20", "dns"=>"puppet1.spence.org.uk.local", "port"=>"10050"}}, "maintenances"=>[], "hostid"=>"10085", "proxy_hostid"=>"0", "host"=>"puppet1.spence.org.uk.local", "status"=>"0", "disable_until"=>"0", "error"=>"", "available"=>"1", "errors_from"=>"0", "lastaccess"=>"0", "ipmi_authtype"=>"0", "ipmi_privilege"=>"2", "ipmi_username"=>"", "ipmi_password"=>"", "ipmi_disable_until"=>"0", "ipmi_available"=>"0", "snmp_disable_until"=>"0", "snmp_available"=>"0", "maintenanceid"=>"0", "maintenance_status"=>"0", "maintenance_type"=>"0", "maintenance_from"=>"0", "ipmi_errors_from"=>"0", "snmp_errors_from"=>"0", "ipmi_error"=>"", "snmp_error"=>"", "jmx_disable_until"=>"0", "jmx_available"=>"0", "jmx_errors_from"=>"0", "jmx_error"=>"", "name"=>"puppet1.spence.org.uk.local"}]

  @doc = <<-EOS
    This type provides the capability to manage hosts in zabbix
  EOS

  ensurable

  newparam(:host, :namevar => true) do
    desc "the name of the hostgroup"
  end

#  newproperty(:ip, :namevar => true) do
#    desc "the ip address of the host"
#    validate do |value|
#      return true if valid_v4?(value)
#      raise Puppet::Error, "Invalid IP address #{value.inspect}"
#    end
#  end

  newproperty(:groups, :array_matching => :all) do
    desc "groups this host is a member of"
    validate do |val|
      fail("group must be a string #{val.inspect}") unless val =~ /^[A-Za-z]+$/
    end
  end

#  newproperty(:dnsname) do
#    desc "dnsname of the thing"
#    validate do |val|
#      fail("groups must be a string #{val.inspect}") unless val =~ /^[A-Za-z]+$/
#    end
#  end
  newproperty(:hostid) do
    validate do |val|
      fail("hostid is read only, meh")
    end

  end

  newproperty(:interfaces, :array_matching => :all) do
    desc "interfaces this host has"
  end

#  pseudoey code for autorequire on hostgroups - not yet tested
#  autorequire(:zabbix_hostgroup) do
#    autos = []
#    if groups = @parameters[:groups]
#      groups.each { |group|
#        if resource = catalog.resources.find { |r| r.is_a?(Puppet::Type.type(:zabbix_hostgroup)) and r.should(:name) == group }
#          autos << resource
#        end
#      end
#    end
#
#  autos
#
#  end

# nicked from the host core type
  def valid_v4?(addr)
    if /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/ =~ addr
      return $~.captures.all? {|i| i = i.to_i; i >= 0 and i <= 255 }
    end
    return false
  end
end
