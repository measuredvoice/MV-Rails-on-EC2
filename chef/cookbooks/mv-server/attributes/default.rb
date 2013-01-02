# override accounts cookbook  file location
set[:accounts][:cookbook] = "mv-server"

# accounts cookbook defaults 
default[:accounts][:default][:file_backup] = 2
default[:accounts][:default][:group] ="users" 
default[:accounts][:default][:do_ssh] = "true"
default[:accounts][:default][:do_sudo] = "false"
default[:accounts][:default][:sudo] = "false"

# default syslog source
default[:syslog_ng][:source] = "syslog-ng/syslog-ng_client.conf"

