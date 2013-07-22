cookbook_file "/root/backup.py" do
  source "ebs_snapshot.py"
  mode 0755
  action :create_if_missing
end

command = "/root/backup.py --verbose --awskeys #{node[:backup][:aws_access_key_id]}:#{node[:backup][:aws_secret_access_key]} "
command += "--mount #{node[:backup][:mount_point]} "
if node[:opsworks][:instance][:layers].include?('mongo')
	command += "-l mongodb:slaveonly=true "
end
if node[:opsworks][:instance][:layers].include?('db-master') 
	command += "-l mysql:user=root:password=#{node[:backup][:mysql_pw]} "
end

cron "backup" do
	action :create
	minute "0"
	hour "0"
	day "*"
	command command
end

