set[:mongodb][:cluster_name] = node[:opsworks][:stack][:name]
set[:mongodb][:replicaset_name] = "rs_#{node[:opsworks][:stack][:name]}"
set[:mongodb][:replicaset_members] = node[:opsworks][:layers][:mongo][:instances].values.map{ |instance| instance[:ip]}
set[:mongodb][:dbpath] = "/vol/mongodb"
set[:mongodb][:journalpath] = "/vol/mongodb/journal"

#set[:mongodb][:apt_repo] = "ubuntu-upstart"
