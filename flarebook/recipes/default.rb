packages = []

case node[:platform]
when 'debian', 'ubuntu'
  packages = [
    'htop',
    'dstat',
    'iftop',
    'ec2-api-tools',
    'build-essentials',
    'python-pip',
    'mercurial'
  ]
end

packages.each do |pkg|
  package pkg do
    action :install
  end
end