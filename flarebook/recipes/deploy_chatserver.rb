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
      :monitored_script => "#{deploy[:deploy_to]}/current/src/nodejs/main.js"
    )
    notifies :restart, resources(:service => 'monit'), :immediately
  end
  
  ruby_block "install npm dependencies" do
		block do
			if deploy[:auto_npm_install_on_deploy]
				OpsWorks::NodejsConfiguration.npm_install(application, deploy, "#{deploy[:deploy_to]}/current/src/nodejs")
			end
		end	
	end

end