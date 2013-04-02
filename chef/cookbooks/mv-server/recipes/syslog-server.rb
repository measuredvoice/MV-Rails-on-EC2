#############################################
# mv-server::syslog-server recipe
#
#   Build a server for syslog-server
#############################################

# common stuff
include_recipe "mv-server::default"

# syslog-ng
node.set[:syslog_ng][:source] = "syslog-ng/syslog-ng_server.conf"
include_recipe "mv-server::syslog"

# support scripts
cookbook_file "/usr/local/bin/compress_logs" do
  source "bin/compress_logs"
  owner "root"
  group "root"
  mode 00750
  action :create_if_missing
end

cookbook_file "/usr/local/bin/maintain_links" do
  source "bin/maintain_links"
  owner "root"
  group "root"
  mode 00750
  action :create_if_missing
end

# crontab files
# log compression
# 1 0 * * *       root    /usr/local/bin/compress_logs >/dev/null 2>&1
cron "compress-logs" do
   hour "0"
   minute "1"
   command "/usr/local/bin/compress_logs >/dev/null 2>&1"
end

# maintain links
# */10 * * * *       root    /usr/local/bin/maintain_links >/dev/null 2>&1
cron "maintain-links" do
   hour "*"
   minute "*/10"
   command "/usr/local/bin/maintain_links >/dev/null 2>&1"
end

