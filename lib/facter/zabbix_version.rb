#a comment
Facter.add("zabbix_version") do
    zabbix_out = Facter::Util::Resolution.exec('zabbix_server --version').split(' ')
    setcode do
      zabbix_out[2].sub(/^v/,'')
    end
end
