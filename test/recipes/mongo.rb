

node.set[:mongodb][:cluster_name] = node[:opsworks][:stack][:name]
node.set[:mongodb][:replicaset_name] = "rs_#{node[:opsworks][:stack][:name]}"
if node[:opsworks][:layers][:mongo] != 0 and not node[:opsworks][:layers][:mongo][:instances].empty?
	node.set[:mongodb][:replicaset_members] = node[:opsworks][:layers][:mongo][:instances].values.map{ |instance| instance[:private_dns_name]}
end
if node[:opsworks][:layers][:arbiter] != 0 and not node[:opsworks][:layers][:arbiter][:instances].empty?
	node.set[:mongodb][:replicaset_arbiters] = node[:opsworks][:layers][:arbiter][:instances].values.map{ |instance| instance[:private_dns_name]}
end
node.set[:mongodb][:dbpath] = "/vol/mongodb"
node.set[:mongodb][:journalpath] = "/vol/mongodb/journal"
node.set[:mongodb][:use_fqdn] = false

include_recipe "mongodb::default"

=begin
cron "backup_mongodb" do
	#action node.tags.include?('cookbooks-report') ? :create : :delete
	action :create
	minute "0"
	hour "0"
	day "*"
	user "opscode"
	home "/srv/opscode-community-site/shared/system"
	command %Q{
		backup/mongo_backup.py --awskeys #{node[:aws_access_id]}:#{node[:aws_access_key]} --mount #{node[:mongodb][:dbpath]}
	} #--verbose --dryrun
end=end


