Puppet::Type.newtype(:zabbix_host) do

  @doc = <<-EOS
    This type provides the capability to manage hosts in zabbix
  EOS

  ensurable

  newparam(:host, :namevar => true) do
    desc "the name of the hostgroup"
  end

  newparam(:ip, :namevar => true) do
    desc "the ip address of the host"
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
