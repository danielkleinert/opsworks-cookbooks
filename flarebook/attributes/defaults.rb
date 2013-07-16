#
# Nodejs
#
set[:mongodb][:cluster_name] = "game"
set[:mongodb][:replicaset_name] = "game"
if node[:opsworks][:layers][:mongo] != 0 and not node[:opsworks][:layers][:mongo][:instances].empty?
	set[:mongodb][:replicaset_members] = node[:opsworks][:layers][:mongo][:instances].values.map{ |instance| instance[:private_dns_name]}
end
if node[:opsworks][:layers][:arbiter] != 0 and not node[:opsworks][:layers][:arbiter][:instances].empty?
	set[:mongodb][:replicaset_arbiters] = node[:opsworks][:layers][:arbiter][:instances].values.map{ |instance| instance[:private_dns_name]}
end
node.set[:mongodb][:use_fqdn] = false

if node[:opsworks][:instance][:layers].include?("mongo")
	#i am a mongo instance
	set[:mongodb][:dbpath] = "/vol/mongodb"
	set[:mongodb][:journalpath] = "/vol/mongodb/journal"
elsif node[:opsworks][:instance][:layers].include?("arbiter")
	# i am only an arbiter
	set[:mongodb][:smallfiles] = true
	set['mongodb']['auto_configure']['replicaset'] = false
end

#
# MySQL
#
set[:mysql][:datadir] = "/vol/mysql"

#
# Gameserver
#
# TODO: this does not work!
#default[:deploy][:gameserver][:main_script] = 'main_gok.js'

default[:gameserver][:live] = 0
default[:gameserver][:rccheckerip] = nil
default[:gameserver][:serverid] = node[:opsworks][:stack][:name]
default[:gameserver][:masterurl] = nil
# Needs load balancer; set via stack json!
default[:gameserver][:boardurl] = nil  

#
# Bord
#
default[:forum][:mbname] = nil
default[:forum][:language] = "english"
default[:forum][:boardurl] = nil
default[:forum][:webmaster_email] = nil
default[:forum][:db_name] = "smf_board"



# set[:deploy][:cloudwatch][:deploy_to] = '/opt/cloudwatch'
# set[:deploy][:cloudwatch][:release_path] = "#{node[:deploy][:cloudwatch][:deploy_to]}/releases/#{node[:deploy][:cloudwatch][:release]}"
# set[:deploy][:cloudwatch][:current_path] = "#{node[:deploy][:cloudwatch][:deploy_to]}/current"
# set[:deploy][:cloudwatch][:absolute_document_root] = "#{default[:deploy][:cloudwatch][:current_path]}/"
# set[:deploy][:cloudwatch][:user] = "root"
# set[:deploy][:cloudwatch][:group] = "root"
# set[:deploy][:cloudwatch][:home] = "/root"
# default[:deploy][application][:stack][:needs_reload] = true

