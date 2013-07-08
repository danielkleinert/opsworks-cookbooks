package node[:mongodb][:package_name] do
  action :install
  version node[:mongodb][:package_version]
end

#chef_gem 'bson_ext'
#chef_gem 'mongo'

gem_package 'bson_ext' do
	action :nothing
end.run_action(:install)
Gem.clear_paths

gem_package 'mongo' do
	action :nothing
end.run_action(:install)
Gem.clear_paths


if node.recipe?("mongodb::default") or node.recipe?("mongodb")
  # configure default instance
  mongodb_instance "mongodb" do
    mongodb_type "mongod"
    bind_ip      node['mongodb']['bind_ip']
    port         node['mongodb']['port']
    logpath      node['mongodb']['logpath']
    dbpath       node['mongodb']['dbpath']
    enable_rest  node['mongodb']['enable_rest']
    smallfiles   node['mongodb']['smallfiles']
    auth         node['mongodb']['auth']
  end
end
