if node[:deploy].attribute?(:forum)

	execute 'smfupdate' do
		command '/usr/bin/php #{node[:deploy][:forum][:deploy_to]}/current/src/php/smfupdate.php'
		action :nothing
	end

	include_recipe 'apache2::service'

	mongos = node[:mongodb][:replicaset_members].join(',') rescue ''

	template "#{node[:deploy][:forum][:deploy_to]}/shared/config/Settings.php" do
	    source 'forum_settings.php.erb'
	    mode '0660'
	    owner node[:deploy][:forum][:user]
	    group node[:deploy][:forum][:group]
	    variables(
	    	:mbname => node[:forum][:mbname],
			:language => node[:forum][:language],
			:boardurl => node[:forum][:boardurl],
			:webmaster_email => node[:forum][:webmaster_email],
			:db_server => node[:deploy][:forum][:database][:host],
			:db_name => node[:deploy][:forum][:database][:database],
			:db_user => node[:deploy][:forum][:database][:username],
			:db_passwd => node[:deploy][:forum][:database][:password],
			:db_mongo_server => mongos,
			:db_mongo_db => "kd2_mnt",
			:db_mongo_replset => node[:mongodb][:replicaset_name],
			:base_dir => "#{node[:deploy][:forum][:deploy_to]}/current/src/php"
		)
		notifies :restart, resources(:service => 'apache2'), :delayed
		notifies :run, 'execute[smfupdate]', :delayed
	end

end