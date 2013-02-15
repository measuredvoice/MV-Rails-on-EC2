#################################################################
# Capistrano capfile for setup of servers for
# Measured Voice cl_dash sercers
#
# adh - 20120210
#
# Requires user with sudo access on CentOS 5.x ot RHEL 5.x


#################################################################
# Define servers
server "ec2-184-72-64-170.compute-1.amazonaws.com", :cldash
server "ec2-67-202-42-163.compute-1.amazonaws.com", :ringsail
server "ec2-23-22-138-70.compute-1.amazonaws.com", :mv2app


#################################################################
# Misc Tasks (for testing access)
desc "Echo the server's uptime"
task :uptime do
  run "uptime"
  default_run_options[:pty] = true
  sudo "uptime"
end

desc "Echo the server's hostname"
task :hostname do
  run "echo `hostname`"
end

#################################################################
# Install requisite base packages by server type
namespace :cl_dash do
   default_run_options[:pty] = true

   desc "install epel repo"
   task :install_epelrepo, :roles => :cldash do
      sudo "rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-7.noarch.rpm"
   end

   desc "common packages"
   task :install_commonpackages, :roles => :cldash  do
      sudo "yum -y -q install screen nginx git-all rpm-build redhat-rpm-config unifdefi readline readline-devel ncurses ncurses-devel gdbm gdbm-devel glibc-devel tcl-devel gcc unzip openssl-devel db4-devel byacc make gcc-c++ ntpdate"
   end

   desc "install ruby 1.9.2 (from rpm)"
   task :install_ruby, :roles => :cldash  do
      upload("./rpms/el6/x86_64/ruby-1.9.2p290-3.el6.x86_64.rpm","/tmp/ruby-1.9.2p290-3.el6.x86_64.rpm", :mode => 0600)
      sudo "yum -y -q  localinstall /tmp/ruby-1.9.2p290-3.el6.x86_64.rpm"
      sudo "rm -f /tmp/ruby-1.9.2p290-3.el6.x86_64.rpm" 
   end

   desc "update gem >= 1.8"
   task :update_gem, :roles => :cldash  do
      sudo "gem update --system"
   end

   desc "install bundler"
   task :install_bundler, :roles => :cldash  do
      sudo "gem install bundler"
   end

   desc "install Percona MySQL 5.5"
   task :install_percona, :roles => :cldash do
      sudo "rpm -Uhv http://www.percona.com/downloads/percona-release/percona-release-0.0-1.x86_64.rpm"
      sudo "yum -y -q install Percona-Server-shared-compat.x86_64 Percona-Server-client-55 Percona-Server-server-55 Percona-Server-devel-55.x86_64" 
      upload("./etc/my.cnf.cl_dash","/tmp/my.cnf.cl_dash", :mode => 0644)
      sudo "cp /tmp/my.cnf.cl_dash /etc"
      sudo "mv -f /etc/my.cnf /etc/my.cnf.orig"
      sudo "ln -s /etc/my.cnf.cl_dash /etc/my.cnf"
      sudo "rm -f /tmp/my.cnf.cl_dash"
      sudo "/etc/init.d/mysql start"
      sudo "chkconfig mysql on"
      sudo "mysqladmin -u root password cl_dash2012"
      upload("./etc/.my.cnf.cl_dash.root","/tmp/.my.cnf.cl_dash.root", :mode => 0600)
      sudo "cp -pf /tmp/.my.cnf.cl_dash.root /root/.my.cnf" 
      sudo "rm -f /tmp/.my.cnf.cl_dash.root"
   end
   
   desc "create database for cl_dash"
   task :create_db, :roles => :cldash do
      sudo "mysql -e 'create database cl_dash'"
   end

   desc "add account to deploy to"
   task :add_role_account, :roles => :cldash do
      sudo "useradd mv -c 'Measured Voice Deploy' -u 33001 -m -s /bin/bash"
      sudo "mkdir -p /home/mv/.ssh"
      sudo "chmod 700 /home/mv/.ssh"
      upload("./keys/mv_deploy_key.pub","/tmp/mv_deploy_key.pub", :mode => 0600)
      sudo "cp -f /tmp/mv_deploy_key.pub /home/mv/.ssh/authorized_keys"
      run "rm -f /tmp/mv_deploy_key.pub"
      sudo "chmod 600 /home/mv/.ssh/authorized_keys"
      sudo "chown -R mv.mv /home/mv/.ssh"
   end

   desc "nginx config install"
   task :install_nginx_config, :roles => :cldash do
      system "tar czf /tmp/cl_dash_nginx_config.tgz ./etc/nginx"
      run "mkdir -p /tmp/cl_dash_nginx_config"
      upload("/tmp/cl_dash_nginx_config.tgz", "/tmp/cl_dash_nginx_config/cl_dash_nginx_config.tgz", :mode => 0600)
      run "cd /tmp/cl_dash_nginx_config ; tar xf cl_dash_nginx_config.tgz" 
      sudo "cp -fr /tmp/cl_dash_nginx_config/etc/nginx/* /etc/nginx/"
      sudo "mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig"
      sudo "ln -s /etc/nginx/nginx_cldash.conf /etc/nginx/nginx.conf"
      run "rm -rf /tmp/cl_dash_nginx_config"
      system "rm -f /tmp/cl_dash_nginx_config.tgz"
      sudo "/etc/init.d/nginx restart"
   end

   desc "install Node.js"
   task :install_nodejs, :roles => :cldash do
      run "cd /tmp ; wget http://nodejs.tchol.org/repocfg/el/nodejs-stable-release.noarch.rpm"
      sudo "yum -y -q localinstall --nogpgcheck /tmp/nodejs-stable-release.noarch.rpm"
      sudo "yum -y -q install nodejs"
   end

   desc "install ntpdate cron"
   task :install_ntpdate_cron, :roles => :cldash do
      upload("./crontabs/ntpdate_root","/tmp/ntpdate_root", :mode => 0644)
      sudo "chown root.root /tmp/ntpdate_root"
      sudo "mv /tmp/ntpdate_root /etc/cron.d"
   end

   #################################################################
   # cl_dash install all packages
   desc "all tasks to create a cl_dash server"
   task :install, :roles => :cldash  do
      install_epelrepo 
      install_commonpackages 
      install_ntpdate_cron
      install_percona
      install_ruby
      update_gem
      install_bundler   
      add_role_account
      install_nodejs
      install_nginx_config
      create_db
   end
end

namespace :mvserver do
   default_run_options[:pty] = true

   desc "install epel repo"
   task :install_epelrepo, :roles => :mvserver do
      sudo "rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-7.noarch.rpm ; true"
   end

   desc "update all rpms"
   task :yum_update, :roles => :mvserver do
      sudo "yum -y -q update"
   end

   desc "common packages"
   task :install_commonpackages, :roles => :mvserver  do
      sudo "yum -y -q install screen git-all rpm-build redhat-rpm-config unifdefi readline readline-devel ncurses ncurses-devel gdbm gdbm-devel glibc-devel tcl-devel gcc unzip openssl-devel db4-devel byacc make ImageMagick.x86_64 libxml2-devel.x86_64 libxslt-devel.x86_64 memcached gcc-c++.x86_64 ntpdate"
   end

   desc "nginx"
   task :install_nginx, :roles => :mvserver  do
      upload("./etc/yum.repos.d/nginx.repo","/tmp/nginx.repo", :mode => 0644)
      sudo "mv -f /tmp/nginx.repo /etc/yum.repos.d"
      sudo "yum -y -q install nginx"
   end

   desc "install ruby 1.9.2 (from rpm)"
   task :install_ruby192, :roles => :mvserver  do
      upload("./rpms/el6/x86_64/ruby-1.9.2p290-3.el6.x86_64.rpm","/tmp/ruby-1.9.2p290-3.el6.x86_64.rpm", :mode => 0600)
      sudo "yum -y -q  localinstall /tmp/ruby-1.9.2p290-3.el6.x86_64.rpm"
      sudo "rm -f /tmp/ruby-1.9.2p290-3.el6.x86_64.rpm" 
   end

   desc "install ruby 1.9.3 (from rpm)"
   task :install_ruby, :roles => :mvserver  do
      upload("./rpms/el6/x86_64/ruby-1.9.3p327-1.el6.x86_64.rpm","/tmp/ruby-1.9.3p327-1.el6.x86_64.rpm", :mode => 0600)
      sudo "yum -y -q  localinstall /tmp/ruby-1.9.3p327-1.el6.x86_64.rpm"
      sudo "rm -f /tmp/ruby-1.9.3p327-1.el6.x86_64.rpm" 
   end

   desc "update to  ruby 1.9.3 (from rpm)"
   task :update_ruby, :roles => :mvserver  do
      upload("./rpms/el6/x86_64/ruby-1.9.3p327-1.el6.x86_64.rpm","/tmp/ruby-1.9.3p327-1.el6.x86_64.rpm", :mode => 0600)
      sudo "yum -y remove ruby-1.9.2p290"
      sudo "yum -y -q  localinstall /tmp/ruby-1.9.3p327-1.el6.x86_64.rpm"
      sudo "rm -f /tmp/ruby-1.9.3p327-1.el6.x86_64.rpm" 
   end

   desc "update gem >= 1.8"
   task :update_gem, :roles => :mvserver  do
      sudo "gem update --system"
   end

   desc "install bundler"
   task :install_bundler, :roles => :mvserver  do
      sudo "gem install bundler"
   end

   desc "install Percona MySQL 5.5 Client"
   task :install_percona, :roles => :mvserver do
      sudo "rpm -Uhv http://www.percona.com/downloads/percona-release/percona-release-0.0-1.x86_64.rpm; true"
      sudo "yum -y -q install Percona-Server-shared-compat.x86_64 Percona-Server-client-55 Percona-Server-devel-55.x86_64" 
   end
   
   desc "add account to deploy to"
   task :add_role_account, :roles => :mvserver do
      sudo "useradd mv -c 'Measured Voice Deploy' -u 33001 -m -s /bin/bash"
      sudo "mkdir -p /home/mv/.ssh"
      sudo "chmod 700 /home/mv/.ssh"
      upload("./keys/mv_deploy_key.pub","/tmp/mv_deploy_key.pub", :mode => 0600)
      sudo "cp -f /tmp/mv_deploy_key.pub /home/mv/.ssh/authorized_keys"
      run "rm -f /tmp/mv_deploy_key.pub"
      sudo "chmod 600 /home/mv/.ssh/authorized_keys"
      sudo "chown -R mv.mv /home/mv/.ssh"
   end

   desc "add deploy keys for github"
   task :add_deploy_keys, :roles => :mvserver do
      upload("./keys/git_mv_deploy_key","/tmp/git_deploy_key", :mode => 0600)
      upload("./keys/git_mv_deploy_key.pub","/tmp/git_deploy_key.pub", :mode => 0644)
      sudo "cp -f /tmp/git_deploy_key /home/mv/.ssh/id_rsa"
      sudo "cp -f /tmp/git_deploy_key.pub /home/mv/.ssh/id_rsa.pub"
      run "rm -f /tmp/git_deploy_key"
      run "rm -f /tmp/git_deploy_key.pub"
      sudo "chmod 600 /home/mv/.ssh/id_rsa"
      sudo "chmod 644 /home/mv/.ssh/id_rsa.pub"

      sudo "chown -R mv.mv /home/mv/.ssh"
   end

   desc "nginx config install"
   task :install_nginx_config, :roles => :mvserver do
      system "tar czf /tmp/cl_dash_nginx_config.tgz ./etc/nginx"
      run "mkdir -p /tmp/cl_dash_nginx_config"
      upload("/tmp/cl_dash_nginx_config.tgz", "/tmp/cl_dash_nginx_config/cl_dash_nginx_config.tgz", :mode => 0600)
      run "cd /tmp/cl_dash_nginx_config ; tar xf cl_dash_nginx_config.tgz" 
      sudo "cp -fr /tmp/cl_dash_nginx_config/etc/nginx/* /etc/nginx/"
      sudo "mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig"
      sudo "ln -s /etc/nginx/nginx_mv2app.conf /etc/nginx/nginx.conf"
      run "rm -rf /tmp/cl_dash_nginx_config"
      system "rm -f /tmp/cl_dash_nginx_config.tgz"
      sudo "/etc/init.d/nginx restart"
   end

   desc "nginx config update"
   task :update_nginx_config, :roles => :mvserver do
      upload("./etc/nginx/nginx_mv2app.conf","/tmp/nginx_mv2app.conf", :mode => 0644)
      upload("./etc/nginx/conf.d/mv2app_vhost.conf","/tmp/mv2app_vhost.conf", :mode => 0644)
      upload("./etc/nginx/conf.d/admin.conf","/tmp/admin.conf", :mode => 0644)
      upload("./etc/nginx/conf.d/admin_ip_map.conf","/tmp/admin_ip_map.conf", :mode => 0640)
      sudo "cp -f /tmp/nginx_mv2app.conf /etc/nginx/nginx_mv2app.conf"
      sudo "cp -f /tmp/mv2app_vhost.conf /tmp/admin.conf /tmp/admin_ip_map.conf /etc/nginx/conf.d/"
      sudo "service nginx reload"
   end

   desc "install Node.js"
   task :install_nodejs, :roles => :mvserver do
      run "cd /tmp ; wget http://nodejs.tchol.org/repocfg/el/nodejs-stable-release.noarch.rpm"
      sudo "yum -y -q localinstall --nogpgcheck /tmp/nodejs-stable-release.noarch.rpm"
      sudo "yum -y -q install nodejs"
   end

   desc "configure syslog-ng server"
   task :configure_syslog_ng, :roles => :mvserver do
      sudo "yum -y -q install syslog-ng syslog-ng-devel syslog-ng-libdbi"
      sudo "service rsyslog stop"
      sudo "chkconfig rsyslog off"
      upload("./etc/syslog-ng/syslog-ng_client.conf_mv","/tmp/syslog-ng_client.conf", :mode => 0644)
      sudo "mv /etc/syslog-ng/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf-"
      sudo "mv /tmp/syslog-ng_client.conf /etc/syslog-ng/syslog-ng.conf"
      sudo "chown root.root /etc/syslog-ng/syslog-ng.conf"
      sudo "service syslog-ng start"
   end

   desc "update syslog-ng server"
   task :update_syslog_ng, :roles => :mvserver do
      upload("./etc/syslog-ng/syslog-ng_client.conf_mv","/tmp/syslog-ng_client.conf", :mode => 0644)
      sudo "mv /etc/syslog-ng/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf-"
      sudo "mv /tmp/syslog-ng_client.conf /etc/syslog-ng/syslog-ng.conf"
      sudo "chown root.root /etc/syslog-ng/syslog-ng.conf"
      sudo "service syslog-ng restart"
   end

   desc "log rotation configuration "
   task :install_logrotate, :roles => :mvserver do
      upload("./etc/logrotate.d/unicorn_mv2app","/tmp/unicorn_mv2app.logrotate", :mode => 0644)
      sudo "chown root.root /tmp/unicorn_mv2app.logrotate"
      sudo "mv /tmp/unicorn_mv2app.logrotate /etc/logrotate.d/unicorn_mv2app"
   end

   desc "install ntpdate cron"
   task :install_ntpdate_cron, :roles => :mvserver do
      upload("./crontabs/ntpdate_root","/tmp/ntpdate_root", :mode => 0644)
      sudo "chown root.root /tmp/ntpdate_root"
      sudo "mv /tmp/ntpdate_root /etc/cron.d"
   end

   desc "nagios client install"
   task :install_nagios_client, :roles => :mvserver do
      sudo "yum -y -q install nrpe nagios-plugins-disk"
      upload("./etc/nagios/nrpe.cfg","/tmp/nrpe.cfg", :mode => 0644)
      sudo "chown root.root /tmp/nrpe.cfg"
      sudo "mv /etc/nagios/nrpe.cfg /etc/nagios/nrpe.cfg.orig"
      sudo "mv /tmp/nrpe.cfg /etc/nagios/nrpe.cfg"
      sudo "pidof nrpe || sudo /etc/init.d/nrpe start"
   end

   #################################################################
   # mv server install all packages
   desc "all tasks to create a mv dev server"
   task :install, :roles => :mvserver  do
      install_epelrepo 
      yum_update
      install_commonpackages 
      install_ntpdate_cron
      install_nginx
      install_percona
      install_ruby
      update_gem
      install_bundler   
      add_role_account
      add_deploy_keys
      install_nodejs
      install_nginx_config
      configure_syslog_ng
      install_logrotate
      install_nagios_client
   end
end

namespace :threepserver do
   default_run_options[:pty] = true

   desc "install epel repo"
   task :install_epelrepo, :roles => :threepserver do
      sudo "rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-7.noarch.rpm ; true"
   end

   desc "update all rpms"
   task :yum_update, :roles => :threepserver do
      sudo "yum -y -q update"
   end

   desc "common packages"
   task :install_commonpackages, :roles => :threepserver  do
      sudo "yum -y -q install screen git-all rpm-build redhat-rpm-config unifdefi readline readline-devel ncurses ncurses-devel gdbm gdbm-devel glibc-devel tcl-devel gcc unzip openssl-devel db4-devel byacc make iImageMagick.x86_64 libxml2-devel.x86_64 libxslt-devel.x86_64 memcached gcc-c++.x86_64 ntpdate"
   end

   desc "nginx"
   task :install_nginx, :roles => :threepserver  do
      upload("./etc/yum.repos.d/nginx.repo","/tmp/nginx.repo", :mode => 0644)
      sudo "mv -f /tmp/nginx.repo /etc/yum.repos.d"
      sudo "yum -y -q install nginx"
   end

   desc "install ruby 1.9.2 (from rpm)"
   task :install_ruby192, :roles => :threepserver  do
      upload("./rpms/el6/x86_64/ruby-1.9.2p290-3.el6.x86_64.rpm","/tmp/ruby-1.9.2p290-3.el6.x86_64.rpm", :mode => 0600)
      sudo "yum -y -q  localinstall /tmp/ruby-1.9.2p290-3.el6.x86_64.rpm"
      sudo "rm -f /tmp/ruby-1.9.2p290-3.el6.x86_64.rpm" 
   end

   desc "install ruby 1.9.3 (from rpm)"
   task :install_ruby, :roles => :threepserver  do
      upload("./rpms/el6/x86_64/ruby-1.9.3p327-1.el6.x86_64.rpm","/tmp/ruby-1.9.3p327-1.el6.x86_64.rpm", :mode => 0600)
      sudo "yum -y -q  localinstall /tmp/ruby-1.9.3p327-1.el6.x86_64.rpm"
      sudo "rm -f /tmp/ruby-1.9.3p327-1.el6.x86_64.rpm" 
   end

   desc "update to ruby 1.9.3 (from rpm)"
   task :update_ruby, :roles => :threepserver  do
      upload("./rpms/el6/x86_64/ruby-1.9.3p327-1.el6.x86_64.rpm","/tmp/ruby-1.9.3p327-1.el6.x86_64.rpm", :mode => 0600)
      sudo "yum -y remove ruby-1.9.2p290"
      sudo "yum -y -q  localinstall /tmp/ruby-1.9.3p327-1.el6.x86_64.rpm"
      sudo "rm -f /tmp/ruby-1.9.3p327-1.el6.x86_64.rpm" 
   end

   desc "update gem >= 1.8"
   task :update_gem, :roles => :threepserver  do
      sudo "gem update --system"
   end

   desc "install bundler"
   task :install_bundler, :roles => :threepserver  do
      sudo "gem install bundler"
   end

   desc "install Percona MySQL 5.5 Client"
   task :install_percona, :roles => :threepserver do
      sudo "rpm -Uhv http://www.percona.com/downloads/percona-release/percona-release-0.0-1.x86_64.rpm; true"
      sudo "yum -y -q install Percona-Server-shared-compat.x86_64 Percona-Server-client-55 Percona-Server-devel-55.x86_64" 
   end
   
   desc "add account to deploy to"
   task :add_role_account, :roles => :threepserver do
      sudo "useradd mv -c 'Measured Voice Deploy' -u 33001 -m -s /bin/bash"
      sudo "mkdir -p /home/mv/.ssh"
      sudo "chmod 700 /home/mv/.ssh"
      upload("./keys/mv_deploy_key.pub","/tmp/mv_deploy_key.pub", :mode => 0600)
      sudo "cp -f /tmp/mv_deploy_key.pub /home/mv/.ssh/authorized_keys"
      run "rm -f /tmp/mv_deploy_key.pub"
      sudo "chmod 600 /home/mv/.ssh/authorized_keys"
      sudo "chown -R mv.mv /home/mv/.ssh"
   end

   desc "add deploy keys for github"
   task :add_deploy_keys, :roles => :threepserver do
      upload("./keys/git_3p_deploy_key","/tmp/git_deploy_key", :mode => 0600)
      upload("./keys/git_3p_deploy_key.pub","/tmp/git_deploy_key.pub", :mode => 0644)
      sudo "cp -f /tmp/git_deploy_key /home/mv/.ssh/id_rsa"
      sudo "cp -f /tmp/git_deploy_key.pub /home/mv/.ssh/id_rsa.pub"
      run "rm -f /tmp/git_deploy_key"
      run "rm -f /tmp/git_deploy_key.pub"
      sudo "chmod 600 /home/mv/.ssh/id_rsa"
      sudo "chmod 644 /home/mv/.ssh/id_rsa.pub"

      sudo "chown -R mv.mv /home/mv/.ssh"
   end

   desc "nginx config install"
   task :install_nginx_config, :roles => :threepserver do
      system "tar czf /tmp/cl_dash_nginx_config.tgz ./etc/nginx"
      run "mkdir -p /tmp/cl_dash_nginx_config"
      upload("/tmp/cl_dash_nginx_config.tgz", "/tmp/cl_dash_nginx_config/cl_dash_nginx_config.tgz", :mode => 0600)
      run "cd /tmp/cl_dash_nginx_config ; tar xf cl_dash_nginx_config.tgz" 
      sudo "cp -fr /tmp/cl_dash_nginx_config/etc/nginx/* /etc/nginx/"
      sudo "mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig"
      sudo "ln -s /etc/nginx/nginx_3p.conf /etc/nginx/nginx.conf"
      run "rm -rf /tmp/cl_dash_nginx_config"
      system "rm -f /tmp/cl_dash_nginx_config.tgz"
      sudo "/etc/init.d/nginx restart"
   end

   desc "nginx config update"
   task :update_nginx_config, :roles => :threepserver do
      upload("./etc/nginx/nginx_3p.conf","/tmp/nginx_3p.conf", :mode => 0644)
      upload("./etc/nginx/conf.d/3p_vhost.conf","/tmp/3p_vhost.conf", :mode => 0644)
      upload("./etc/nginx/conf.d/3p_secret_key.conf","/tmp/3p_secret_key.conf", :mode => 0640)
      upload("./etc/nginx/conf.d/admin.conf","/tmp/admin.conf", :mode => 0644)
      upload("./etc/nginx/conf.d/admin_ip_map.conf","/tmp/admin_ip_map.conf", :mode => 0640)
      sudo "cp -f nginx_3p.conf /etc/nginx/nginx_3p.conf"
      sudo "cp -f /tmp/3p_vhost.conf /tmp/3p_secret_key.conf /tmp/admin.conf /tmp/admin_ip_map.conf /etc/nginx/conf.d/"
      sudo "service nginx reload"
   end

   desc "install Node.js"
   task :install_nodejs, :roles => :threepserver do
      run "cd /tmp ; wget http://nodejs.tchol.org/repocfg/el/nodejs-stable-release.noarch.rpm"
      sudo "yum -y -q localinstall --nogpgcheck /tmp/nodejs-stable-release.noarch.rpm"
      sudo "yum -y -q install nodejs"
   end

   desc "configure syslog-ng server"
   task :configure_syslog_ng, :roles => :threepserver do
      sudo "yum -y -q install syslog-ng syslog-ng-devel syslog-ng-libdbi"
      sudo "service rsyslog stop"
      sudo "chkconfig rsyslog off"
      upload("./etc/syslog-ng/syslog-ng_client.conf_3p","/tmp/syslog-ng_client.conf", :mode => 0644)
      sudo "mv /etc/syslog-ng/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf-"
      sudo "mv /tmp/syslog-ng_client.conf /etc/syslog-ng/syslog-ng.conf"
      sudo "chown root.root /etc/syslog-ng/syslog-ng.conf"
      sudo "service syslog-ng start"
   end

   desc "update syslog-ng server"
   task :update_syslog_ng, :roles => :threepserver do
      upload("./etc/syslog-ng/syslog-ng_client.conf_3p","/tmp/syslog-ng_client.conf", :mode => 0644)
      sudo "mv /etc/syslog-ng/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf-"
      sudo "mv /tmp/syslog-ng_client.conf /etc/syslog-ng/syslog-ng.conf"
      sudo "chown root.root /etc/syslog-ng/syslog-ng.conf"
      sudo "service syslog-ng restart"
   end

   desc "log rotation configuration "
   task :install_logrotate, :roles => :threepserver do
      upload("./etc/logrotate.d/unicorn_3p","/tmp/unicorn_3p.logrotate", :mode => 0644)
      sudo "chown root.root /tmp/unicorn_3p.logrotate"
      sudo "mv /tmp/unicorn_3p.logrotate /etc/logrotate.d/unicorn_3p"
   end

   desc "install ntpdate cron"
   task :install_ntpdate_cron, :roles => :threepserver do
      upload("./crontabs/ntpdate_root","/tmp/ntpdate_root", :mode => 0644)
      sudo "chown root.root /tmp/ntpdate_root"
      sudo "mv /tmp/ntpdate_root /etc/cron.d"
   end

   desc "nagios client install"
   task :install_nagios_client, :roles => :threepserver do
      sudo "yum -y -q install nrpe nagios-plugins-disk"
      upload("./etc/nagios/nrpe.cfg","/tmp/nrpe.cfg", :mode => 0644)
      sudo "chown root.root /tmp/nrpe.cfg"
      sudo "mv /etc/nagios/nrpe.cfg /etc/nagios/nrpe.cfg.orig"
      sudo "mv /tmp/nrpe.cfg /etc/nagios/nrpe.cfg"
      sudo "pidof nrpe || sudo /etc/init.d/nrpe start"
   end

   #################################################################
   # threep server install all packages
   desc "all tasks to create a mv dev server"
   task :install, :roles => :threepserver  do
      install_epelrepo 
      yum_update
      install_commonpackages 
      install_ntpdate_cron
      install_nginx
      install_percona
      install_ruby
      update_gem
      install_bundler   
      add_role_account
      add_deploy_keys
      install_nodejs
      install_nginx_config
      configure_syslog_ng
      install_logrotate
      install_nagios_client
   end
end

# ringsail server
namespace :ringsail do
   default_run_options[:pty] = true

   desc "install epel repo"
   task :install_epelrepo, :roles => :ringsail do
      sudo "rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm"
   end

   desc "common packages"
   task :install_commonpackages, :roles => :ringsail  do
      sudo "yum -y -q install screen nginx git-all rpm-build redhat-rpm-config unifdefi readline readline-devel ncurses ncurses-devel gdbm gdbm-devel glibc-devel tcl-devel gcc unzip openssl-devel db4-devel byacc make gcc-c++ curl-devel zlib-devel ntpdate"
   end

   desc "install ruby 1.9.2 (from rpm)"
   task :install_ruby192, :roles => :ringsail  do
      upload("./rpms/el5/x86_64/ruby-1.9.2p290-3.x86_64.rpm","/tmp/ruby-1.9.2p290-3.x86_64.rpm", :mode => 0600)
      sudo "yum -y -q --nogpgcheck  localinstall /tmp/ruby-1.9.2p290-3.x86_64.rpm"
      sudo "rm -f /tmp/ruby-1.9.2p290-3.x86_64.rpm" 
   end

   desc "install ruby 1.9.3 (from rpm)"
   task :install_ruby, :roles => :ringsail  do
      upload("./rpms/el5/x86_64/ruby-1.9.3p374-1.x86_64.rpm","/tmp/ruby-1.9.3p374-1.x86_64.rpm", :mode => 0600)
      upload("./rpms/el5/x86_64/yaml-0.1.4-1.x86_64.rpm","/tmp/yaml-0.1.4-1.x86_64.rpm", :mode => 0600)
      sudo "yum -y -q --nogpgcheck localinstall /tmp/yaml-0.1.4-1.x86_64.rpm /tmp/ruby-1.9.3p374-1.x86_64.rpm"
      sudo "rm -f /tmp/ruby-1.9.3p374-1.x86_64.rpm" 
      sudo "rm -f /tmp/yaml-0.1.4-1.x86_64.rpm" 
   end

   desc "update gem >= 1.8"
   task :update_gem, :roles => :ringsail  do
      sudo "gem update --system"
   end

   desc "install bundler"
   task :install_bundler, :roles => :ringsail  do
      sudo "gem install bundler"
   end

   desc "install Percona MySQL 5.5"
   task :install_percona, :roles => :ringsail do
      sudo "rpm -Uhv http://www.percona.com/downloads/percona-release/percona-release-0.0-1.x86_64.rpm"
      sudo "yum -y -q install Percona-Server-shared-compat.x86_64 Percona-Server-client-55 Percona-Server-server-55 Percona-Server-devel-55.x86_64" 
      upload("./etc/my.cnf.ringsail","/tmp/my.cnf.ringsail", :mode => 0644)
      sudo "cp /tmp/my.cnf.ringsail /etc"
      sudo "ln -s /etc/my.cnf.ringsail /etc/my.cnf"
      sudo "rm -f /tmp/my.cnf.ringsail"
      sudo "/etc/init.d/mysql start"
      sudo "/sbin/chkconfig mysql on"
      sudo "mysqladmin -u root password ringsail2012"
      upload("./etc/.my.cnf.ringsail.root","/tmp/.my.cnf.ringsail.root", :mode => 0600)
      sudo "cp -pf /tmp/.my.cnf.ringsail.root /root/.my.cnf" 
      sudo "cp -pf /tmp/.my.cnf.ringsail.root /home/mv/.my.cnf" 
      sudo "chown mv.mv /home/mv/.my.cnf"
      sudo "rm -f /tmp/.my.cnf.ringsail.root"
   end

   desc "create database for ringsail"
   task :create_db, :roles => :ringsail do
      sudo "sudo -i mysqladmin create ringsail_production"
   end

   desc "install latest Apache"
   task :install_apache, :roles => :ringsail do
      sudo "yum -y install httpd httpd-devel apr-devel apr-util-devel"
   end

   desc "install Phusion Passenger"
   task :install_passenger, :roles => :ringsail do
      sudo "gem install passenger"
      sudo "passenger-install-apache2-module --auto"
   end

   desc "add account to deploy to"
   task :add_role_account, :roles => :ringsail do
      sudo "/usr/sbin/useradd mv -c 'Measured Voice Deploy' -u 33001 -m -s /bin/bash"
      sudo "mkdir -p /home/mv/.ssh"
      sudo "chmod 700 /home/mv/.ssh"
      upload("./keys/mv_deploy_key.pub","/tmp/mv_deploy_key.pub", :mode => 0600)
      sudo "cp -f /tmp/mv_deploy_key.pub /home/mv/.ssh/authorized_keys"
      run "rm -f /tmp/mv_deploy_key.pub"
      sudo "chmod 600 /home/mv/.ssh/authorized_keys"
      sudo "chown -R mv.mv /home/mv/.ssh"
   end

   desc "install Node.js"
   task :install_nodejs, :roles => :ringsail do
      run "cd /tmp ; wget http://nodejs.tchol.org/repocfg/el/nodejs-stable-release.noarch.rpm"
      sudo "yum -y -q localinstall --nogpgcheck /tmp/nodejs-stable-release.noarch.rpm"
      sudo "yum -y -q install nodejs"
   end

   desc "apache config install"
   task :install_apache_config, :roles => :ringsail do
      upload("./etc/httpd/conf.d/ringsail.conf", "/tmp/ringsail.conf", :mode => 0644)
      upload("./etc/httpd/conf/httpd.conf", "/tmp/httpd.conf", :mode => 0644)
      sudo "cp -f /tmp/ringsail.conf /etc/httpd/conf.d"
      sudo "cp -f /tmp/httpd.conf /etc/httpd/conf"
      system "rm -f /tmp/ringsail.conf /tmp/httpd.conf"
      sudo "/etc/init.d/httpd restart"
   end

   desc "install ntpdate cron"
   task :install_ntpdate_cron, :roles => :ringsail do
      upload("./crontabs/ntpdate_root","/tmp/ntpdate_root", :mode => 0644)
      sudo "chown root.root /tmp/ntpdate_root"
      sudo "mv /tmp/ntpdate_root /etc/cron.d"
   end

   #################################################################
   # ringsail install all packages
   desc "all tasks to create a ringsail server"
   task :install, :roles => :ringsail  do
      install_epelrepo 
      install_commonpackages 
      install_ntpdate_cron
      add_role_account
      install_percona
      install_ruby
      update_gem
      install_bundler
      install_apache
      install_passenger
      install_nodejs
      install_apache_config
      create_db
   end
end

namespace :mv2app do
   default_run_options[:pty] = true

   desc "install epel repo"
   task :install_epelrepo, :roles => :mv2app do
      sudo "rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-7.noarch.rpm"
   end

   desc "common packages"
   task :install_commonpackages, :roles => :mv2app  do
      sudo "yum -y -q install screen nginx git-all rpm-build redhat-rpm-config unifdefi readline readline-devel ncurses ncurses-devel gdbm gdbm-devel glibc-devel tcl-devel gcc unzip openssl-devel db4-devel byacc make libxml2 libxml2-devel libxslt libxslt-devel ntpdate"
   end

   desc "install ruby 1.9.2 (from rpm)"
   task :install_ruby, :roles => :mv2app  do
      upload("./rpms/el6/x86_64/ruby-1.9.2p290-3.el6.x86_64.rpm","/tmp/ruby-1.9.2p290-3.el6.x86_64.rpm", :mode => 0600)
      sudo "yum -y -q  localinstall /tmp/ruby-1.9.2p290-3.el6.x86_64.rpm"
      sudo "rm -f /tmp/ruby-1.9.2p290-3.el6.x86_64.rpm" 
   end

   desc "update gem >= 1.8"
   task :update_gem, :roles => :mv2app  do
      sudo "gem update --system"
   end

   desc "install bundler"
   task :install_bundler, :roles => :mv2app  do
      sudo "gem install bundler"
   end

   desc "install Percona MySQL 5.5"
   task :install_percona, :roles => :mv2app do
      sudo "rpm -Uhv http://www.percona.com/downloads/percona-release/percona-release-0.0-1.x86_64.rpm"
      sudo "yum -y -q install Percona-Server-shared-compat.x86_64 Percona-Server-client-55 Percona-Server-server-55 Percona-Server-devel-55.x86_64" 
      upload("./etc/my.cnf.mv2app","/tmp/my.cnf.mv2app", :mode => 0644)
      sudo "cp /tmp/my.cnf.mv2app /etc"
      sudo "mv -f /etc/my.cnf /etc/my.cnf.orig"
      sudo "ln -s /etc/my.cnf.mv2app /etc/my.cnf"
      sudo "rm -f /tmp/my.cnf.mv2app"
      sudo "/etc/init.d/mysql start"
      sudo "chkconfig mysql on"
      sudo "mysqladmin -u root password mv2app2012"
      upload("./etc/.my.cnf.mv2app.root","/tmp/.my.cnf.mv2app.root", :mode => 0600)
      sudo "cp -pf /tmp/.my.cnf.mv2app.root /root/.my.cnf" 
      sudo "rm -f /tmp/.my.cnf.mv2app.root"
   end
   
   desc "create database for mv2app"
   task :create_db, :roles => :mv2app do
      sudo "mysql -e 'create database mv2app_production'"
   end

   desc "add account to deploy to"
   task :add_role_account, :roles => :mv2app do
      sudo "useradd mv -c 'Measured Voice Deploy' -u 33001 -m -s /bin/bash"
      sudo "mkdir -p /home/mv/.ssh"
      sudo "chmod 700 /home/mv/.ssh"
      upload("./keys/mv_deploy_key.pub","/tmp/mv_deploy_key.pub", :mode => 0600)
      sudo "cp -f /tmp/mv_deploy_key.pub /home/mv/.ssh/authorized_keys"
      run "rm -f /tmp/mv_deploy_key.pub"
      sudo "chmod 600 /home/mv/.ssh/authorized_keys"
      sudo "chown -R mv.mv /home/mv/.ssh"
   end

   desc "nginx config install"
   task :install_nginx_config, :roles => :mv2app do
      system "tar czf /tmp/mv2app_nginx_config.tgz ./etc/nginx"
      run "mkdir -p /tmp/mv2app_nginx_config"
      upload("/tmp/mv2app_nginx_config.tgz", "/tmp/mv2app_nginx_config/mv2app_nginx_config.tgz", :mode => 0600)
      run "cd /tmp/mv2app_nginx_config ; tar xf mv2app_nginx_config.tgz" 
      sudo "cp -fr /tmp/mv2app_nginx_config/etc/nginx/* /etc/nginx/"
      sudo "mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig"
      sudo "ln -s /etc/nginx/nginx_mv2app.conf /etc/nginx/nginx.conf"
      run "rm -rf /tmp/mv2app_nginx_config"
      system "rm -f /tmp/mv2app_nginx_config.tgz"
      sudo "/etc/init.d/nginx restart"
   end

   desc "install Node.js"
   task :install_nodejs, :roles => :mv2app do
      run "cd /tmp ; wget http://nodejs.tchol.org/repocfg/el/nodejs-stable-release.noarch.rpm"
      sudo "yum -y -q localinstall --nogpgcheck /tmp/nodejs-stable-release.noarch.rpm"
      sudo "yum -y -q install nodejs"
   end

   desc "install ntpdate cron"
   task :install_ntpdate_cron, :roles => :mv2app do
      upload("./crontabs/ntpdate_root","/tmp/ntpdate_root", :mode => 0644)
      sudo "chown root.root /tmp/ntpdate_root"
      sudo "mv /tmp/ntpdate_root /etc/cron.d"
   end

   #################################################################
   # mv2app install all packages
   desc "all tasks to create a mv2app server"
   task :install, :roles => :mv2app  do
      install_epelrepo 
      install_commonpackages 
      install_ntpdate_cron
      install_percona
      install_ruby
      update_gem
      install_bundler   
      add_role_account
      install_nodejs
      install_nginx_config
      create_db
   end
end


namespace :mvsyslog do
   default_run_options[:pty] = true

   desc "install epel repo"
   task :install_epelrepo, :roles => :mvsyslog do
      sudo "rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-7.noarch.rpm ; true"
   end

   desc "update all rpms"
   task :yum_update, :roles => :mvsyslog do
      sudo "yum -y -q update"
   end

   desc "common packages"
   task :install_commonpackages, :roles => :mvsyslog  do
      sudo "yum -y -q install screen git-all rpm-build redhat-rpm-config unifdefi readline readline-devel ncurses ncurses-devel gdbm gdbm-devel glibc-devel tcl-devel gcc unzip openssl-devel db4-devel byacc make iImageMagick.x86_64 libxml2-devel.x86_64 libxslt-devel.x86_64 memcached gcc-c++.x86_64 java-1.6.0-openjdk.x86_64 syslog-ng syslog-ng-devel syslog-ng-libdbi ntpdate"
   end

   desc "configure syslog-ng server"
   task :configure_syslog_ng, :roles => :mvsyslog do
      sudo "service rsyslog stop"
      sudo "chkconfig rsyslog off"
      upload("./etc/syslog-ng/syslog-ng_server.conf","/tmp/syslog-ng_server.conf", :mode => 0644)
      sudo "mv /etc/syslog-ng/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf-"
      sudo "mv /tmp/syslog-ng_server.conf /etc/syslog-ng/syslog-ng.conf"
      sudo "chown root.root /etc/syslog-ng/syslog-ng.conf"
      sudo "service syslog-ng start"

      # log rotation
      upload("./bin/compress_logs", "/tmp/compress_logs", :mode => 0744) 
      upload("./bin/maintain_links", "/tmp/maintain_links", :mode => 0744) 
      sudo "mv -f /tmp/compress_logs /usr/local/bin/compress_logs"
      sudo "mv -f /tmp/maintain_links /usr/local/bin/maintain_links"
      upload("./crontabs/syslog_root", "/tmp/syslog_root", :mode => 0644)
      sudo "mv -f /tmp/syslog_root /etc/cron.d/syslog_root"
      sudo "chown root.root /etc/cron.d/syslog_root"
   end

   desc "update syslog-ng server"
   task :update_syslog_ng, :roles => :mvsyslog do
      upload("./etc/syslog-ng/syslog-ng_server.conf","/tmp/syslog-ng_server.conf", :mode => 0644)
      sudo "mv /etc/syslog-ng/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf-"
      sudo "mv /tmp/syslog-ng_server.conf /etc/syslog-ng/syslog-ng.conf"
      sudo "chown root.root /etc/syslog-ng/syslog-ng.conf"
      sudo "service syslog-ng restart"

      # log rotation
      upload("./bin/compress_logs", "/tmp/compress_logs", :mode => 0744) 
      upload("./bin/maintain_links", "/tmp/maintain_links", :mode => 0744) 
      sudo "mv -f /tmp/compress_logs /usr/local/bin/compress_logs"
      sudo "mv -f /tmp/maintain_links /usr/local/bin/maintain_links"
      upload("./crontabs/syslog_root", "/tmp/syslog_root", :mode => 0644)
      sudo "mv -f /tmp/syslog_root /etc/cron.d/syslog_root"
      sudo "chown root.root /etc/cron.d/syslog_root"
   end

   desc "install ntpdate cron"
   task :install_ntpdate_cron, :roles => :mvserver do
      upload("./crontabs/ntpdate_root","/tmp/ntpdate_root", :mode => 0644)
      sudo "chown root.root /tmp/ntpdate_root"
      sudo "mv /tmp/ntpdate_root /etc/cron.d"
   end

   desc "nginx"
   task :install_nginx, :roles => :mvsyslog  do
      upload("./etc/yum.repos.d/nginx.repo","/tmp/nginx.repo", :mode => 0644)
      sudo "mv -f /tmp/nginx.repo /etc/yum.repos.d"
      sudo "yum -y -q install nginx"
   end

   desc "elasticsearch"
   task :install_elasticsearch, :roles => :mvsyslog do
      upload("./bin/install_elasticsearch.sh","/tmp/install_elasticsearch.sh", :mode => 0755)
      sudo "/tmp/install_elasticsearch.sh"
      sudo "rm -f /tmp/install_elasticsearch.sh"
   end

   desc "mongodb"
   task :install_mongodb, :roles => :mvsyslog  do
      sudo "curl -qO http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/RPMS/mongo-10gen-2.0.7-mongodb_1.x86_64.rpm"
      sudo "curl -qO http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/RPMS/mongo-10gen-server-2.0.5-mongodb_1.x86_64.rpm"
      sudo "rpm -Uvh *mongo*.rpm"
      sudo "rm mongo-10gen-2.0.7-mongodb_1.x86_64.rpm mongo-10gen-server-2.0.5-mongodb_1.x86_64.rpm"
      sudo "mkdir -p /var/lib/mongodb"
      sudo "chown -R mongodb:mongodb /var/lib/mongodb/"
      sudo "chkconfig mongod on"
      sudo "service mongod start"
      upload("./etc/mongo/dbsetup.txt","/tmp/dbsetup.txt", :mode => 0600)
      sudo "mongo < /tmp/dbsetup.txt"
   end

   desc "install ruby 1.9.2 (from rpm)"
   task :install_ruby, :roles => :mvsyslog  do
      upload("./rpms/el6/x86_64/ruby-1.9.2p290-3.el6.x86_64.rpm","/tmp/ruby-1.9.2p290-3.el6.x86_64.rpm", :mode => 0600)
      sudo "yum -y -q  localinstall /tmp/ruby-1.9.2p290-3.el6.x86_64.rpm"
      sudo "rm -f /tmp/ruby-1.9.2p290-3.el6.x86_64.rpm" 
   end

   desc "update gem >= 1.8"
   task :update_gem, :roles => :mvsyslog  do
      sudo "gem update --system"
   end

   desc "install bundler"
   task :install_bundler, :roles => :mvsyslog  do
      sudo "gem install bundler"
   end

   desc "nginx config install"
   task :install_nginx_config, :roles => :mvsyslog do
      system "tar czf /tmp/cl_dash_nginx_config.tgz ./etc/nginx"
      run "mkdir -p /tmp/cl_dash_nginx_config"
      upload("/tmp/cl_dash_nginx_config.tgz", "/tmp/cl_dash_nginx_config/cl_dash_nginx_config.tgz", :mode => 0600)
      run "cd /tmp/cl_dash_nginx_config ; tar xf cl_dash_nginx_config.tgz" 
      sudo "cp -fr /tmp/cl_dash_nginx_config/etc/nginx/* /etc/nginx/"
      sudo "mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig"
      sudo "ln -s /etc/nginx/nginx_mv2app.conf /etc/nginx/nginx.conf"
      run "rm -rf /tmp/cl_dash_nginx_config"
      system "rm -f /tmp/cl_dash_nginx_config.tgz"
      sudo "/etc/init.d/nginx restart"
   end

   desc "nginx config update"
   task :update_nginx_config, :roles => :mvsyslog do
      upload("./etc/nginx/nginx_mv2app.conf","/tmp/nginx_mv2app.conf", :mode => 0644)
      upload("./etc/nginx/conf.d/mv2app_vhost.conf","/tmp/mv2app_vhost.conf", :mode => 0644)
      upload("./etc/nginx/conf.d/admin.conf","/tmp/admin.conf", :mode => 0644)
      upload("./etc/nginx/conf.d/admin_ip_map.conf","/tmp/admin_ip_map.conf", :mode => 0640)
      sudo "cp -f nginx_mv2app.conf /etc/nginx/nginx_mv2app.conf"
      sudo "cp -f /tmp/mv2app_vhost.conf /tmp/admin.conf /tmp/admin_ip_map.conf /etc/nginx/conf.d/"
      sudo "service nginx reload"
   end

   #################################################################
   # mv syslog install all packages
   #desc "all tasks to create a mv syslog server with graylog2" # TBD at some point
   desc "all tasks to create a mv syslog server"
   task :install, :roles => :mvsyslog  do
      install_epelrepo 
      yum_update
      install_commonpackages 
      install_ntpdate_cron
      configure_syslog_ng
      #install_elasticsearch
      #install_mongodb
      #install_nginx
      #install_ruby
      #update_gem
      #install_bundler   
      #add_role_account
      #install_nginx_config
   end
end

namespace :mvmonitor do
   default_run_options[:pty] = true

   desc "install epel repo"
   task :install_epelrepo, :roles => :mvmonitor do
      sudo "rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-7.noarch.rpm ; true"
   end

   desc "install rpmforge repo"
   task :install_rpmforgerepo, :roles => :mvmonitor do
      sudo "rpm -Uvh http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm ; true"
      sudo "rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt ; true"
   end

   desc "common packages"
   task :install_commonpackages, :roles => :mvmonitor  do
      sudo "yum -y -q install screen git-all rpm-build redhat-rpm-config unifdefi readline readline-devel ncurses ncurses-devel gdbm gdbm-devel glibc-devel tcl-devel gcc unzip openssl-devel db4-devel byacc make iImageMagick.x86_64 libxml2-devel.x86_64 libxslt-devel.x86_64 memcached gcc-c++.x86_64 java-1.6.0-openjdk.x86_64 syslog-ng syslog-ng-devel syslog-ng-libdbi ntpdate"
   end

   desc "update all rpms"
   task :yum_update, :roles => :mvmonitor do
      sudo "yum -y -q update"
   end

   desc "configure syslog-ng server"
   task :configure_syslog_ng, :roles => :mvmonitor do
      sudo "yum -y -q install syslog-ng syslog-ng-devel syslog-ng-libdbi"
      sudo "service rsyslog stop"
      sudo "chkconfig rsyslog off"
      upload("./etc/syslog-ng/syslog-ng_client.conf_monitor","/tmp/syslog-ng_client.conf", :mode => 0644)
      sudo "mv /etc/syslog-ng/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf-"
      sudo "mv /tmp/syslog-ng_client.conf /etc/syslog-ng/syslog-ng.conf"
      sudo "chown root.root /etc/syslog-ng/syslog-ng.conf"
      sudo "service syslog-ng start"
   end

   desc "update syslog-ng server"
   task :update_syslog_ng, :roles => :mvmonitor do
      upload("./etc/syslog-ng/syslog-ng_client.conf_monitor","/tmp/syslog-ng_client.conf", :mode => 0644)
      sudo "mv /etc/syslog-ng/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf-"
      sudo "mv /tmp/syslog-ng_client.conf /etc/syslog-ng/syslog-ng.conf"
      sudo "chown root.root /etc/syslog-ng/syslog-ng.conf"
      sudo "service syslog-ng restart"
   end

   desc "uninstall nginx (if exists)"
   task :remove_nginx, :roles => :mvmonitor do
      sudo "yum -y remove nginx"
   end

   desc "install apache"
   task :install_apache, :roles => :mvmonitor do
      sudo "yum -y -q install httpd httpd-tools"
   end

   desc "update_apache_config"
   task :update_apache_config, :roles => :mvmonitor do
      upload("./etc/httpd/icinga/httpd.conf","/tmp/httpd.conf", :mode => 0644)
      sudo "mv /tmp/httpd.conf /etc/httpd/conf/httpd.conf"
      upload("./etc/httpd/icinga/icinga.conf","/tmp/icinga.conf", :mode => 0644)
      sudo "mv /tmp/icinga.conf /etc/httpd/conf.d/icinga.conf"
   end

   desc "install nagios plugins"
   task :install_nagios_plugins, :roles => :mvmonitor do
      sudo "yum -y -q install nagios-plugins.x86_64 nagios-plugins-all.x86_64 nagios-plugins-nrpe"
   end

   desc "install icinga and any supporting packages"
   task :install_icinga, :roles => :mvmonitor do
      sudo "yum -y -q install icinga.x86_64 icinga-idoutils.x86_64 icinga-gui.x86_64 icinga-doc.x86_64 icinga-api.x86_64"
      sudo "/etc/init.d/icinga start"
      sudo "chkconfig icinga on"
   end

   desc "update icinga users"
   task :update_icinga_users, :roles => :mvmonitor do
      upload("./etc/icinga/htpasswd.users","/tmp/htpasswd.users", :mode => 0644)
      sudo "mv /tmp/htpasswd.users /etc/icinga/htpasswd.users" 
      sudo "chown root.root /etc/icinga/htpasswd.users"
   end

   desc "update icinga config"
   task :update_icinga_config, :roles => :mvmonitor do
      upload("./etc/icinga","/tmp/icinga_config", :via => :scp, :recursive => true)
      sudo "chown -R icinga.icinga /tmp/icinga_config"
      sudo "chown root.root /tmp/icinga_config/htpasswd.users"
      sudo "chmod 644 /tmp/icinga_config/htpasswd.users"
      sudo "rsync -axv /tmp/icinga_config/ /etc/icinga" 
      sudo "rm -rf /tmp/icinga_config"
   end

   desc "install ntpdate cron"
   task :install_ntpdate_cron, :roles => :mv2app do
      upload("./crontabs/ntpdate_root","/tmp/ntpdate_root", :mode => 0644)
      sudo "chown root.root /tmp/ntpdate_root"
      sudo "mv /tmp/ntpdate_root /etc/cron.d"
   end

   #################################################################
   # mv syslog install all packages
   desc "all tasks to create a mv monitoring server"
   task :install, :roles => :mvmonitor  do
      install_epelrepo 
      install_rpmforgerepo
      yum_update
      install_commonpackages 
      install_ntpdate_cron
      configure_syslog_ng
      remove_nginx
      install_apache
      update_apache_config
      install_nagios_plugins
      install_icinga
      update_icinga_users
      #update_icinga_config
   end
end
