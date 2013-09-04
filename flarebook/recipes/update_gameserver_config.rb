require 'json'

if node[:deploy].attribute?(:gameserver)

	deploy = node[:deploy][:gameserver]
	application = :gameserver

	#hack for legacy live server
	serverid = node[:gameserver][:serverid]
	if serverid == "tw-us-vir-1"
		serverid = "live"	
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
			:rccheckerip => node[:gameserver][:rccheckerip],
			:boardurl => node[:gameserver][:boardurl],
			:serverid => serverid,
			:masterurl => node[:gameserver][:masterurl]
		)
	end

	ruby_block "restart node.js application #{application}" do
		block do
		  Chef::Log.info("restart node.js via: #{node[:deploy][application][:nodejs][:restart_command]}")
		  Chef::Log.info(`#{node[:deploy][application][:nodejs][:restart_command]}`)
		  $? == 0
		end	
	end

end
