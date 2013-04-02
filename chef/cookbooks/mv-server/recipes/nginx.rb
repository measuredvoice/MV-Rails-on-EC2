# add nginxrepo
yum_repository "nginx" do
   name "nginx"
   url "http://nginx.org/packages/centos/$releasever/$basearch/"
   action :add
end

# setup install
node.set[:nginx][:version] = "1.2.6"

node.set['nginx']['user'] = "mv"
node.set['nginx']['init_style'] = "init"
node.set['nginx']['dir'] = "/etc/nginx"
node.set['nginx']['log_dir'] = "/var/log/nginx"
node.set['nginx']['worker_processes'] = 8
node.set['nginx']['worker_connections'] = 4096
node.set['nginx']['keepalive_timeout'] = 65

include_recipe "nginx"

