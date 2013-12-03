if node[:deploy].attribute?(:chatserver)
  
  application = :chatserver
  deploy = node[:deploy][application]
	

  template "#{node[:monit][:conf_dir]}/node_web_app-#{application}.monitrc" do
    source 'chatserver.monitrc.erb'
    cookbook 'flarebook'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      :deploy => deploy,
      :application_name => application,
      :monitored_script => "#{deploy[:deploy_to]}/current/src/nodejs/main.js",
      :monitored_port => node['chatserver']['chatserverserviceport']
    )
    notifies :restart, resources(:service => 'monit'), :immediately
  end
  
  template "#{deploy[:deploy_to]}/current/src/nodejs/config.json" do
	    source 'chatserver_config.json.erb'
	    mode '0660'
	    owner deploy[:user]
	    group deploy[:group]
	    variables(
    	:chatserverserviceport => node[:chatserver][:chatserverserviceport],
    	:chatserverport => node[:chatserver][:chatserverport]
		)
	end
  
  ruby_block "install npm dependencies" do
		block do
			if deploy[:auto_npm_install_on_deploy]
				OpsWorks::NodejsConfiguration.npm_install(application, deploy, "#{deploy[:deploy_to]}/current/src/nodejs")
			end
		end	
	end

end