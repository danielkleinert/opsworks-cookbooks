include_recipe 'deploy'

if node[:deploy].attribute?(:cloudwatch)

  deploy = node[:deploy][:cloudwatch]

  if node[:opsworks][:instance][:layers].include?('mongo')
    bash 'install pymongo' do
      user "root"
      code <<-EOH
        pip install pymongo
      EOH
    end
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  template "#{deploy[:deploy_to]}/shared/config/settings.py" do
    source 'settings.py.erb'
    mode '0660'
    owner deploy[:user]
    group deploy[:group]
    variables(
        :aws_access_key_id => node[:cloudwatch][:aws_access_key_id],
        :aws_secret_access_key => node[:cloudwatch][:aws_secret_access_key],
        :namespace => node[:cloudwatch][:namespace],
        :update_interval => node[:cloudwatch][:update_interval],
        :monitor_memcached => node[:cloudwatch][:monitor_memcached],
        :monitor_mongo => node[:cloudwatch][:monitor_mongo],
        :monitor_mem => node[:cloudwatch][:monitor_mem],
        :disk_usage_paths => node[:cloudwatch][:disk_usage_paths],
    )
  end

  deploy[:symlink_before_migrate]['#{deploy[:deploy_to]}/current/settings.py'] = "#{deploy[:deploy_to]}/shared/config/settings.py"

  opsworks_deploy do
    deploy_data deploy
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
      :deploy => deploy,
      :monitored_script => "#{deploy[:deploy_to]}/current/server.js"
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
