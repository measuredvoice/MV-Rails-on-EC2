# install packages
package "syslog-ng"
package "syslog-ng-devel"
package "syslog-ng-libdbi"

# syslog config
cookbook_file "/etc/syslog-ng/syslog-ng.conf" do
  source node[:syslog_ng][:source]
  owner "root"
  group "root"
  mode 00644
  notifies :reload, "service[syslog-ng]"
  action :create
end

service "syslog" do
  action [ :disable, :stop ]
end
 
service "rsyslog" do
  action [ :disable, :stop ]
end
 
service "syslog-ng" do
  supports :restart => true, :status => true
  action [ :enable, :start ]
end

