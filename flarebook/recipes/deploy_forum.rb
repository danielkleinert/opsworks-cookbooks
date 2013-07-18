if node[:deploy].attribute?(:forum)

	include_recipe "flarebook::update_forum_config"
	include_recipe 'apache2::service'

	application = :forum

	template "#{node[:apache][:dir]}/sites-available/#{application}.conf.d/local.conf" do
		Chef::Log.debug("Generating Apache local site template for #{application}")
		source 'forum_local.conf.erb'
		owner 'root'
		group 'root'
		mode 0644
	end

	link "#{node[:deploy][:forum][:deploy_to]}/current/src/php/Settings.php" do
	 	owner "deploy"
	 	to "#{node[:deploy][:forum][:deploy_to]}/shared/config/Settings.php"
	 	notifies :restart, resources(:service => 'apache2'), :delayed
	end

end