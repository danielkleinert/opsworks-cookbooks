#
# Cookbook Name:: mongodb
# Provider:: user 
#
# Authors:
#       BK Box <bk@theboxes.org>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


=begin
[Mon, 08 Jul 2013 13:50:16 +0000] DEBUG: Loading cookbook chef-mongodb's providers from /opt/aws/opsworks/current/site-cookbooks/chef-mongodb/providers/user.rb
[Mon, 08 Jul 2013 13:50:16 +0000] ERROR: ruby_block[Load the custom cookbooks] (/opt/aws/opsworks/releases/20130628172708_125/cookbooks/opsworks_custom_cookbooks/recipes/load.rb:10:in `from_file') had an error:
wrong constant name Chef-mongodbUser
/opt/aws/opsworks/releases/20130628172708_125/vendor/bundle/ruby/1.8/gems/chef-0.9.15.5/bin/../lib/chef/provider.rb:89:in `const_defined?'
/opt/aws/opsworks/releases/20130628172708_125/vendor/bundle/ruby/1.8/gems/chef-0.9.15.5/bin/../lib/chef/provider.rb:89:in `build_from_file'
/opt/aws/opsworks/releases/20130628172708_125/vendor/bundle/ruby/1.8/gems/chef-0.9.15.5/bin/../lib/chef/run_context.rb:66:in `load'
=end

=begin
action :add do
  unless Chef::MongoDB.user_exists?(node, new_resource.name, new_resource.password, new_resource.database)
    Chef::MongoDB.configure_user(node, new_resource.name, new_resource.password, new_resource.database)
  end
end

action :delete do
  Chef::MongoDB.configure_user(node, new_resource.name, new_resource.password, new_resource.database, :delete => true)
end

action :update do
  Chef::MongoDB.configure_user(node, new_resource.name, new_resource.password, new_resource.database)
end
=end
