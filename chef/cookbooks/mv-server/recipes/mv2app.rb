#############################################
# mv-server::mv2app recipe
#
#   Build a server for mv2app
#############################################

# common stuff
include_recipe "mv-server::default"

# nginx and mv server config
include_recipe "mv-server::nginx"

# install percona mysql client
include_recipe "percona-install::client"

# install node js
#include_recipe "nodejs::install_from_package"
include_recipe "nodejs"

# install ruby
include_recipe "mv-server::install_ruby"

# syslog-ng
node[:syslog_ng][:source] = "syslog-ng/syslog-ng_client.conf_mv"
include_recipe "mv-server::syslog"

# initial code deploy (?)

# nginx config
node['nginx']['default_site_enabled'] = false

cookbook_file "#{node[:nginx][:dir]}/sites-available/mv2app_vhost.conf" do
   source "nginx/mv2app_vhost.conf"
   owner "root"
   group "root"
   mode 00644
   notifies :reload, "service[nginx]"
end

cookbook_file "#{node[:nginx][:dir]}/healthcheck.conf" do
   source "nginx/healthcheck.conf"
   owner "root"
   group "root"
   mode 00644
   notifies :reload, "service[nginx]"
end

cookbook_file "#{node[:nginx][:dir]}/status.conf" do
   source "nginx/status.conf"
   owner "root"
   group "root"
   mode 00644
   notifies :reload, "service[nginx]"
end

cookbook_file "#{node[:nginx][:dir]}/star_measuredvoice_com.pem" do
   source "nginx/star_measuredvoice_com.pem"
   owner "root"
   group "root"
   mode 00644
   notifies :reload, "service[nginx]"
end

execute "enable mv2app vhost" do
  command "/usr/sbin/nxensite mv2app_vhost.conf"
  action :run
end

execute "remove default.conf if it exists" do
  command "mv -f /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.orig || true"
  action :run
end

execute "disable default vhost" do
  command "/usr/sbin/nxdissite default"
  action :run
end

# logrotation script for unicorn
cookbook_file "/etc/logrotate.d/unicorn_mv2app" do
   source "logrotate.d/unicorn_mv2app"
   owner "root"
   group "root"
   mode 00640
end

