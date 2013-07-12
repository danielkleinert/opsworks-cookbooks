include_recipe "flarebook::update_gameserver_config"

deploy = node[:deploy][:gameserver]
application = :gameserver

link "#{deploy[:deploy_to]}/src/nodejs/config.json" do
  	to "#{deploy[:deploy_to]}/shared/config/gameserver_config.json"
end

ruby_block "restart node.js application #{application}" do
	block do
	  Chef::Log.info("restart node.js via: #{node[:deploy][application][:nodejs][:restart_command]}")
	  Chef::Log.info(`#{node[:deploy][application][:nodejs][:restart_command]}`)
	  $? == 0
	end	
end
