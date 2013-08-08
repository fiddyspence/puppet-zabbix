module Puppet::Parser::Functions
  newfunction(:interfacefactstohash, :type =>:rvalue, :doc => <<-EOT
    Module specific implementation to generate an appropriate hash for zabbix
    Example:
      $module_path = get_module_path('stdlib')
  EOT
  ) do |args|
    raise(Puppet::ParseError, "interfacefactstohash(): Wrong number of arguments, expects none") unless args.size == 0

      return 'nothing here yet - move along please'      

    end
  end
end
