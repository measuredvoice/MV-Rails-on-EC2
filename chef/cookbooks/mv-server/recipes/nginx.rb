# add nginxrepo
yum_repository "nginx" do
   name "nginx"
   url "http://nginx.org/packages/centos/$releasever/$basearch/"
   action :add
end

# setup install
node[:nginx][:version] = "1.2.6"

node['nginx']['user'] = "mv"
node['nginx']['init_style'] = "init"
node['nginx']['dir'] = "/etc/nginx"
node['nginx']['log_dir'] = "/var/log/nginx"
node['nginx']['worker_processes'] = 8
node['nginx']['worker_connections'] = 4096
node['nginx']['keepalive_timeout'] = 65

include_recipe "nginx"

