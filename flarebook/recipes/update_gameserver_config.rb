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
			:masterurl => node[:gameserver][:masterurl]
		)
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
