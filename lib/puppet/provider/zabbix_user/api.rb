require 'zabbixapi'

Puppet::Type.type(:zabbix_user).provide(:api) do

  confine  :kernel => 'linux'

  def exists?
    @property_hash[:ensure] == :present
  end

  def self.instances
    instances = []
    moo = connect()
    foo = moo.users.get(:id => 0)
    foo.each do |user|
#{"userid"=>"2", "alias"=>"guest", "name"=>"Default", "surname"=>"User", "url"=>"", "autologin"=>"0", "autologout"=>"900", "lang"=>"en_GB", "refresh"=>"30", "type"=>"1", "theme"=>"default", "attempt_failed"=>"0", "attempt_ip"=>"", "attempt_clock"=>"0", "rows_per_page"=>"50"}
      instances << new(:name => user['alias'], :ensure => :present, :firstname => user['name'], :lastname => user['surname'], :userid => user['userid'])
    end
    instances
  end

  def self.prefetch(user)
    instances.each do |prov|
      if pkg = user[prov.name]
        pkg.provider = prov
      end
    end
  end

  def create
    moo = connect()
    groups = []
    @resource[:groups].each do |group|
      groups << { 'usrgrpid' => moo.usergroups.get_id(:name => group ) }
    end
    moo.users.create(:alias => @resource[:name], :name => @resource[:firstname], :surname => @resource[:lastname], :passwd => @resource[:password], :usrgrps => groups )
  end

  def name
    @property_hash[:name]
  end
  def firstname
    @property_hash[:firstname]
  end
  def lastname
    @property_hash[:lastname]
  end
  def userid
    @property_hash[:userid]
  end
  def password
    @property_hash[:password]
  end
  def groups 
    # @property_hash[:password]
  end
  def connect
    credentials = YAML::load_file('/root/.zabbix')
    connect=ZabbixApi.connect( :url => "http://#{credentials['host']}/zabbix/api_jsonrpc.php", :user => credentials['username'], :password => credentials['password'] )
    return connect
  end
  def self.connect
    credentials = YAML::load_file('/root/.zabbix')
    connect=ZabbixApi.connect( :url => "http://#{credentials['host']}/zabbix/api_jsonrpc.php", :user => credentials['username'], :password => credentials['password'] )
    return connect
  end
end
