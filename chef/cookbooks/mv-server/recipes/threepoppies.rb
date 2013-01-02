#############################################
# mv-server::threepoppies recipe
#
#   Build a server for threepoppies app
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
node[:syslog_ng][:source] = "syslog-ng/syslog-ng_client.conf_3p"
include_recipe "mv-server::syslog"

# initial code deploy (?)

# nginx config
node['nginx']['default_site_enabled'] = false

cookbook_file "#{node[:nginx][:dir]}/sites-available/3p_vhost.conf" do
   source "nginx/3p_vhost.conf"
   owner "root"
   group "root"
   mode 00644
   notifies :reload, "service[nginx]"
end

cookbook_file "#{node[:nginx][:dir]}/3p_secret_key.conf" do
   source "nginx/3p_secret_key.conf"
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

execute "enable 3p vhost" do
  command "/usr/sbin/nxensite 3p_vhost.conf"
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
cookbook_file "/etc/logrotate.d/unicorn_3p" do
   source "logrotate.d/unicorn_3p"
   owner "root"
   group "root"
   mode 00640
end

