
node.set[:mongodb][:cluster_name] = node[:opsworks][:stack][:name]
node.set[:mongodb][:replicaset_name] = "rs_#{node[:opsworks][:stack][:name]}"
if node[:opsworks][:layers][:mongo] != 0 and not node[:opsworks][:layers][:mongo][:instances].empty?
	node.set[:mongodb][:replicaset_members] = node[:opsworks][:layers][:mongo][:instances].values.map{ |instance| instance[:private_dns_name]}
end
if node[:opsworks][:layers][:arbiter] != 0 and not node[:opsworks][:layers][:arbiter][:instances].empty?
	node.set[:mongodb][:replicaset_arbiters] = node[:opsworks][:layers][:arbiter][:instances].values.map{ |instance| instance[:private_dns_name]}
end
node.set[:mongodb][:smallfiles] = true
#node.set[:mongodb][:dbpath] = "/vol/mongodb"
#node.set[:mongodb][:journalpath] = "/vol/mongodb/journal"
node.set[:mongodb][:use_fqdn] = false

include_recipe "mongodb::mongodb"