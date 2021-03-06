require 'json'

if node[:deploy].attribute?(:gameserver)

  package 'rsyslog'

	deploy = node[:deploy][:gameserver]
	application = :gameserver

	#hack for legacy live server
	serverid = node[:gameserver][:serverid]
	if serverid == "tw-us-vir-1"
		serverid = "live"	
	end
	
	service node['rsyslog']['service_name'] do
    supports :restart => true, :reload => true, :status => true
    action   [:enable, :start]
  end
	
	#another hack for memcached
	memcacheip = node[:gameserver][:serverid] + '-game1'

	template "#{deploy[:deploy_to]}/shared/config/gameserver_config.json" do
	    source 'gameserver_config.json.erb'
	    mode '0660'
	    owner deploy[:user]
	    group deploy[:group]
	    variables(
	    	:mongoip => node[:mongodb][:replicaset_members].to_json, 
	    	:master_mongoip => node[:mongodb][:replicaset_members].to_json, 
	    	:mongoreplset => node[:mongodb][:replicaset_name],
			:master_mongoreplset => node[:mongodb][:replicaset_name],
			:memcacheip => node[:gameserver][:memcacheip].to_json,
			:live => node[:gameserver][:live],
			:cluster => node[:gameserver][:cluster],
			:rccheckerip => node[:gameserver][:rccheckerip],
			:boardurl => node[:gameserver][:boardurl],
			:serverid => serverid,
			:hostname => node[:opsworks][:instance][:hostname],
			:masterurl => node[:gameserver][:masterurl],
			:chatserver_host_internal => node[:gameserver][:chatserver_host_internal],
			:chatserver_host_external => node[:gameserver][:chatserver_host_external],
    	:chatserverserviceport => node[:gameserver][:chatserverserviceport],
    	:chatserverport => node[:gameserver][:chatserverport]
		)
	end
	
	template "#{node[:monit][:conf_dir]}/node_web_app-#{application}.monitrc" do
    source 'gameserver.monitrc.erb'
    cookbook 'flarebook'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      :deploy => deploy,
      :application_name => application,
      :monitored_script => "#{deploy[:deploy_to]}/current/src/nodejs/main_gok.js"
    )
    notifies :restart, resources(:service => 'monit'), :delayed
  end
	
	template "#{node['rsyslog']['config_prefix']}/rsyslog.d/60-node_game_server.conf" do
    source  'rsyslog_gameserver.conf.erb'
    owner   'root'
    group   'root'
    mode    '0644'
    variables (
    :deploy => deploy,
    :rsyslog_srv_host => node['rsyslog']['remote_srv_host'],
    :rsyslog_srv_port => node['rsyslog']['remote_srv_port'] )
  end
  
  template "#{node['rsyslog']['config_prefix']}/rsyslog.conf" do
    source  'rsyslog.conf.erb'
    owner   'root'
    group   'root'
    mode    '0644'
  end  
  
  template "/etc/logrotate.d/opsworks_app_#{application}" do
    backup false
    source "logrotate_gameserver.erb"
    cookbook 'flarebook'
    owner "root"
    group "root"
    mode 0644
    variables( :log_dirs => ["#{deploy[:deploy_to]}/shared/log" ] )
  end

	ruby_block "restart node.js application #{application}" do
		block do
		  Chef::Log.info("restart node.js via: #{node[:deploy][application][:nodejs][:restart_command]}")
		  Chef::Log.info(`#{node[:deploy][application][:nodejs][:restart_command]}`)
		  $? == 0
		end	
	end
	
	service node['rsyslog']['service_name'] do
    supports :restart => true, :reload => true, :status => true
    action   :restart
  end

end
