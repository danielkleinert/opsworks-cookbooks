#
# Nodejs
#

set[:opsworks_nodejs][:version] = "0.8.25"
set[:opsworks_nodejs][:deb] = "nodejs_0.8.25-1chl1~precise1_amd64.deb"
set[:opsworks_nodejs][:deb_url] = "http://ppa.launchpad.net/chris-lea/node.js-legacy/ubuntu/pool/main/n/nodejs/nodejs_0.8.25-1chl1~precise1_amd64.deb"

set[:mongodb][:cluster_name] = "game"
set[:mongodb][:replicaset_name] = "game"
if node[:opsworks][:layers][:mongo] != 0 and not node[:opsworks][:layers][:mongo][:instances].empty?
	set[:mongodb][:replicaset_members] = node[:opsworks][:layers][:mongo][:instances].keys()
end
if node[:opsworks][:layers][:arbiter] != 0 and not node[:opsworks][:layers][:arbiter][:instances].empty?
	set[:mongodb][:replicaset_arbiters] = node[:opsworks][:layers][:arbiter][:instances].keys()
end
node.set[:mongodb][:use_fqdn] = false

if node[:opsworks][:instance][:layers].include?("mongo")
	#i am a mongo instance
	set[:mongodb][:dbpath] = "/vol/mongo"
	set[:mongodb][:journalpath] = "/vol/mongodb/journal"
elsif node[:opsworks][:instance][:layers].include?("arbiter")
	# i am only an arbiter
	set[:mongodb][:smallfiles] = true
	set['mongodb']['auto_configure']['replicaset'] = false
end

#
# Gameserver
#
default[:gameserver][:main_script] = 'main_gok.js'
# Bug in node package
#default[:gameserver][:memcacheip] = node[:opsworks][:layers]["nodejs-app"][:instances].values.map{ |instance| instance[:private_dns_name]} rescue []
default[:gameserver][:memcacheip] = ["localhost"]
default[:gameserver][:live] = 0
default[:gameserver][:rccheckerip] = nil
default[:gameserver][:serverid] = node[:opsworks][:stack][:name]
default[:gameserver][:masterurl] = nil
# Needs load balancer; set via stack json!
default[:gameserver][:boardurl] = nil  

if node[:deploy] != 0 and node[:deploy][:gameserver]
	set[:deploy][:gameserver][:nodejs][:restart_command] = "monit restart node_game_server; monit restart node_maintainance_server"
	set[:deploy][:gameserver][:nodejs][:stop_command] = "monit stop node_game_server; monit stop node_maintainance_server"
end

#
# Bord
#
default[:forum][:mbname] = nil
default[:forum][:language] = "english"
default[:forum][:boardurl] = nil
default[:forum][:webmaster_email] = nil
default[:forum][:db_name] = "smf_board"

#
# Backup
#
default[:backup][:mysql_pw] = node[:mysql][:server_root_password]
default[:backup][:mount_point] = node[:ebs][:devices].collect{|device_name, device| device[:mount_point]}.first rescue []
default[:backup][:aws_access_key_id] = nil
default[:backup][:aws_secret_access_key] = nil

