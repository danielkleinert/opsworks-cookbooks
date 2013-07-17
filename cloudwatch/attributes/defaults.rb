require "pathname"

default[:cloudwatch][:aws_access_key_id] = nil
default[:cloudwatch][:aws_secret_access_key] = nil
default[:cloudwatch][:update_interval] = 2
default[:cloudwatch][:namespace] = node[:opsworks][:stack][:name]
default[:cloudwatch][:monitor_memcached] = false
default[:cloudwatch][:monitor_mongo] = node[:opsworks][:instance][:layers].include?('mongo')
default[:cloudwatch][:monitor_mem] = true
default[:cloudwatch][:disk_usage_paths] = Pathname.new("/vol").children.select { |c| c.directory? }.collect { |p| p.to_s }
