#############################################
# mv-server::monitoring-server recipe
#
#   Build a server for monitoring-server
#############################################

# common stuff
include_recipe "mv-server::default"

# syslog-ng client
node.set[:syslog_ng][:source] = "syslog-ng/syslog-ng_client.conf"
include_recipe "mv-server::syslog"

# install.apache
include_recipe "apache2"

# update.apache.config

# install nagios plugins
for pkg in [ 'nagios-plugins.x86_64', 'nagios-plugins-all.x86_64', 'nagios-plugins-nrpe' ] do
   package pkg do
      action :install
   end
end

# install icinga
for pkg in [ 'icinga.x86_64 icinga-idoutils.x86_64 icinga-gui.x86_64 icinga-doc.x86_64 icinga-api.x86_64' ] do
   package pkg do
      action :install
   end
end

service "icinga" do
  supports :restart => true, :status => true
  action [ :enable, :start ]
end

# update icinga users

# update icinga config

