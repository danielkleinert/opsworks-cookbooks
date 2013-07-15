deploy = node[:deploy][:forum]
application = :forum

template "#{deploy[:deploy_to]}/shared/config/Settings.php" do
    source 'bord_settings.php.erb'
    mode '0660'
    owner deploy[:user]
    group deploy[:group]
    variables(
    	:mbname => node[:forum][:mbname],
		:language => node[:forum][:language],
		:boardurl => node[:forum][:boardurl],
		:webmaster_email => node[:forum][:webmaster_email],
		:db_server => deploy[:database][:host],
		:db_name => deploy[:database][:database],
		:db_user => deploy[:database][:username],
		:db_passwd => deploy[:database][:password],
		:db_mongo_server => "",
		:db_mongo_db => "",
		:db_mongo_replset => node[:mongodb][:replicaset_name],
	)
end