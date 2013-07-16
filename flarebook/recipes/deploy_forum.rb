include_recipe "flarebook::update_forum_config"
include_recipe 'apache2::service'

deploy = node[:deploy][:forum]
application = :forum

link "#{deploy[:deploy_to]}/current/src/php/Settings.php" do
 	owner "deploy"
 	to "#{deploy[:deploy_to]}/shared/config/Settings.php"
 	notifies :restart, resources(:service => 'apache2'), :delayed
end