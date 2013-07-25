Puppet::Type.newtype(:zabbix_hostgroup) do

  @doc = <<-EOS
    This type provides the capability to manage hostgroups in zabbix
  EOS

  ensurable

  newparam(:name, :namevar => true) do
    desc "the name of the hostgroup"
  end

  newproperty(:groupid) do
    desc "groupid"
    validate do |val|
      fail "groupid is read-only"
    end
  end

  newproperty(:internal) do
    desc "internal, whatever that means"
  end

end
