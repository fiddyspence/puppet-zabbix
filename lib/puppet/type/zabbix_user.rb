Puppet::Type.newtype(:zabbix_user) do

  @doc = <<-EOS
    This type provides the capability to manage users in zabbix
  EOS

  ensurable

  newparam(:name, :namevar => true) do
    desc "the name of the useruser"
  end

  newproperty(:firstname ) do
    desc "real first name of this user"
    validate do |val|
      fail("firstname must be a string #{val.inspect}") unless val =~ /^[A-Za-z\s]+$/
    end
  end

  newproperty(:lastname ) do
    desc "real last name of this user"
    validate do |val|
      fail("lastname must be a string #{val.inspect}") unless val =~ /^[A-Za-z\s]+$/
    end
  end

  newproperty(:password) do
    desc "the password"

    def insync?(is)
      begin
        require 'zabbixapi'
        credentials = YAML::load_file('/root/.zabbix')
        connect=ZabbixApi.connect( :url => "http://#{credentials['host']}/zabbix/api_jsonrpc.php", :user => @resource[:username], :password => @resource[:password] )
        return true
      rescue
        return false
      end
    end

  end
  newproperty(:userid) do
    desc "the password"
    validate do |foo|
      fail('userid is a readonly at the moment')
    end
  end
  newproperty(:groups, :array_matching => :all) do
    isrequired
    desc "the groups the user belongs to"
    validate do |val|
      fail("lastname must be a string #{val.inspect}") unless val =~ /^[A-Za-z\s]+$/
    end
  end

end
