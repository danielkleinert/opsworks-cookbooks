execute "apt-get update" do
    action :nothing
end

apt_repository "node-legacy" do
    uri "http://ppa.launchpad.net/chris-lea/node.js-legacy/ubuntu"
    distribution "precise"
    components ["main"]
    keyserver "hkp://keyserver.ubuntu.com:80"
    key "C7917B12"
    action :add
    notifies :run, resources(:execute => "apt-get update"), :immediately
end

package "npm" do
	action :install
end