include_recipe 'deploy'

if node[:deploy].attribute?(:cloudwatch)

  # this fucks up chef pretty hard!
  #deploy = node[:deploy][:cloudwatch]

  if node[:opsworks][:instance][:layers].include?('mongo')
    bash 'install pymongo' do
      user "root"
      code <<-EOH
        pip install pymongo
      EOH
    end
  end

  opsworks_deploy_dir do
    user node[:deploy][:cloudwatch][:user]
    group node[:deploy][:cloudwatch][:group]
    path node[:deploy][:cloudwatch][:deploy_to]
  end

  template "#{node[:deploy][:cloudwatch][:deploy_to]}/shared/config/settings.py" do
    source 'settings.py.erb'
    mode '0660'
    owner node[:deploy][:cloudwatch][:user]
    group node[:deploy][:cloudwatch][:group]
    variables(
        :aws_access_key_id => node[:cloudwatch][:aws_access_key_id],
        :aws_secret_access_key => node[:cloudwatch][:aws_secret_access_key],
        :namespace => node[:cloudwatch][:namespace],
        :update_interval => node[:cloudwatch][:update_interval],
        :monitor_memcached => node[:cloudwatch][:monitor_memcached],
        :monitor_mongo => node[:cloudwatch][:monitor_mongo],
        :monitor_mem => node[:cloudwatch][:monitor_mem],
        :disk_usage_paths => node[:cloudwatch][:disk_usage_paths]
    )
  end

  #deploy[:symlink_before_migrate]['#{deploy[:deploy_to]}/current/settings.py'] = "#{deploy[:deploy_to]}/shared/config/settings.py"

  Chef::Log.info("deploy[:group]: #{deploy[:group]}")
  Chef::Log.info("deploy[:user]: #{deploy[:user]}")
  Chef::Log.info("deploy: #{deploy.inspect}")

  opsworks_deploy do
    deploy_data node[:deploy][:cloudwatch]
    app :cloudwatch
  end

  service 'monit' do
    action :nothing
  end


  template "#{node[:monit][:conf_dir]}/cloudwatch.monitrc" do
    source 'cloudwatch.monitrc.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      :deploy => node[:deploy][:cloudwatch],
      :monitored_script => "#{node[:deploy][:cloudwatch][:deploy_to]}/current/server.js"
    )
    notifies :restart, resources(:service => 'monit'), :immediately
  end

  ruby_block "restart cloudwatch" do
    block do
      #Chef::Log.info("restart node.js via: #{node[:deploy][application][:nodejs][:restart_command]}")
      #Chef::Log.info(`#{node[:deploy][application][:nodejs][:restart_command]}`)
      #$? == 0
    end
  end


end 
