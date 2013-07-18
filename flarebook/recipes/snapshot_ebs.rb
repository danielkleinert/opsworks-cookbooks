cookbook_file "/root/backup.py " do
  path "ebs_snapshot.py"
  action :create_if_missing
end

command = "/root/backup.py --verbose --awskeys #{node[:awsaccess][:aws_access_key_id]}:#{node[:awsaccess][:aws_secret_access_key]} "
if node[:opsworks][:instance][:layers].include?('mongo')
	command += "--mount /vol/mongo "
	command += "-l mongodb:slaveonly=true "
elsif node[:opsworks][:instance][:layers].include?('db-master')
	db_pw = node[:deploy][:forum][:database][:password]
	command += "--mount /vol/mysql "
	command += "-l mysql:user=root:password=#{db_pw} "
end

cron "backup" do
	action :create
	minute "0"
	hour "0"
	day "*"
	command command
end

