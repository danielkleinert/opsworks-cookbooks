
if node[:opsworks][:instance][:layers].include?('mongo')
  bash 'install pymongo' do
    user "root"
    code <<-EOH
      pip install pymongo
    EOH
  end
end

directory "/root/cloudwatch" do
  action :delete
  recursive true
end

bash "Configuration of maximum number of open file descriptors" do
  user "root"
  code <<-EOF
      hg clone --insecure #{node[:cloudwatch][:hg_repo]} /root/cloudwatch
  EOF
end 

template "/root/cloudwatch/settings.py" do
  source 'settings.py.erb'
  mode '0660'
  owner node[:deploy][:cloudwatch][:user]
  group node[:deploy][:cloudwatch][:group]
  variables(
      :aws_access_key_id => node[:awsaccess][:aws_access_key_id],
      :aws_secret_access_key => node[:awsaccess][:aws_secret_access_key],
      :namespace => node[:cloudwatch][:namespace],
      :update_interval => node[:cloudwatch][:update_interval],
      :monitor_memcached => node[:cloudwatch][:monitor_memcached],
      :monitor_mongo => node[:cloudwatch][:monitor_mongo],
      :monitor_mem => node[:cloudwatch][:monitor_mem],
      :disk_usage_paths => node[:cloudwatch][:disk_usage_paths]
  )
end

service 'monit' do
  action :nothing
end


template "#{node[:monit][:conf_dir]}/cloudwatch.monitrc" do
  source 'cloudwatch.monitrc.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, resources(:service => 'monit'), :immediately
end

ruby_block "restart cloudwatch" do
  block do
    Chef::Log.info("restart cloudwatch via: monit restart cloudwatch")
    Chef::Log.info(`monit restart cloudwatch`)
    $? == 0
  end
end

