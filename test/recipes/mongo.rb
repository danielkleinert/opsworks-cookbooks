

include_recipe "mongodb::default"

=begin
cron "backup_mongodb" do
	#action node.tags.include?('cookbooks-report') ? :create : :delete
	action :create
	minute "0"
	hour "0"
	day "*"
	command %Q{
		backup/mongo_backup.py --awskeys #{node[:aws_access_id]}:#{node[:aws_access_key]} --mount #{node[:mongodb][:dbpath]}
	} 
end
=end 


