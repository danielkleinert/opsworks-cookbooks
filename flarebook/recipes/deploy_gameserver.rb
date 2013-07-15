include_recipe "flarebook::update_gameserver_config"

deploy = node[:deploy][:gameserver]
application = :gameserver

link "#{deploy[:deploy_to]}/current/src/nodejs/config.json" do
  	user "deploy"
  	to "#{deploy[:deploy_to]}/shared/config/gameserver_config.json"
end

link "#{deploy[:deploy_to]}/current/src/nodejs/log/" do
  	user "deploy"
  	to "#{deploy[:deploy_to]}/shared/log/"
end

ruby_block "install npm dependencies" do
	block do
		if deploy[:auto_npm_install_on_deploy]
			OpsWorks::NodejsConfiguration.npm_install(application, node[:deploy][application], "#{deploy[:deploy_to]}/current/src/nodejs")
		end
	end	
end

bash "initialise database" do 
	cwd "#{deploy[:deploy_to]}/current/src/nodejs/"
	code <<-EOH
		/usr/bin/env NODE_PATH=#{deploy[:deploy_to]}/current/src/nodejs/node_modules:#{deploy[:deploy_to]}/current/src/nodejs /usr/local/bin/node --max-stack-size=65535 -- #{deploy[:deploy_to]}/current/src/nodejs/#{eploy[:main_script] install}
	EOH
end 

ruby_block "restart node.js application #{application}" do
	block do
		Chef::Log.info("restart node.js via: #{node[:deploy][application][:nodejs][:restart_command]}")
		Chef::Log.info(`#{node[:deploy][application][:nodejs][:restart_command]}`)
		$? == 0
	end	
end
