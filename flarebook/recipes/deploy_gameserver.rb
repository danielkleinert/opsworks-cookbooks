if node[:deploy].attribute?(:gameserver)

	include_recipe "flarebook::update_gameserver_config"

	deploy = node[:deploy][:gameserver]
	application = :gameserver

	link "#{deploy[:deploy_to]}/current/src/nodejs/config.json" do
	  	owner "deploy"
	  	to "#{deploy[:deploy_to]}/shared/config/gameserver_config.json"
	end

	link "#{deploy[:deploy_to]}/current/src/nodejs/logs" do
	  	owner "deploy"
	  	to "#{deploy[:deploy_to]}/shared/log/"
	end

	ruby_block "install npm dependencies" do
		block do
			if deploy[:auto_npm_install_on_deploy]
				OpsWorks::NodejsConfiguration.npm_install(application, node[:deploy][application], "#{deploy[:deploy_to]}/current/src/nodejs")
			end
		end	
	end

#	bash "installing native npm dependency mongodb" do
#	  user "root"
#	  cwd "#{deploy[:deploy_to]}/current/src/nodejs"
#	  code <<-EOF
#		npm install mongodb@1.2.14 '--mongodb:native'
#	  EOF
#	end

	file "#{deploy[:deploy_to]}/current/src/nodejs/install.sh" do
		owner "root"
		group "root"
		mode "0755"
		content <<-EOH
			#!/bin/sh
			/usr/bin/env NODE_PATH=#{deploy[:deploy_to]}/current/src/nodejs/node_modules:#{deploy[:deploy_to]}/current/src/nodejs \
			/usr/bin/node --max-stack-size=65535 -- #{deploy[:deploy_to]}/current/src/nodejs/#{node[:gameserver][:main_script]} \
			--cmd install
		EOH
		action :create
	end

	# bash "initialise database" do 
	#	timeout 60 * 60 * 3 # = 3h	
	#	cwd "#{deploy[:deploy_to]}/current/src/nodejs/"
	# 	code <<-EOH
	# 		/usr/bin/env NODE_PATH=#{deploy[:deploy_to]}/current/src/nodejs/node_modules:#{deploy[:deploy_to]}/current/src/nodejs /usr/local/bin/node --max-stack-size=65535 -- #{deploy[:deploy_to]}/current/src/nodejs/#{node[:gameserver][:main_script]} --cmd install
	# 	EOH
	# end 

	ruby_block "restart node.js application #{application}" do
		block do
			Chef::Log.info("restart node.js via: #{node[:deploy][application][:nodejs][:restart_command]}")
			Chef::Log.info(`#{node[:deploy][application][:nodejs][:restart_command]}`)
			$? == 0
		end	
	end

end