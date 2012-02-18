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
server "ec2-184-73-60-5.compute-1.amazonaws.com", :ringsail


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
      sudo "rpm -Uvh http://download.fedora.redhat.com/pub/epel/6/x86_64/epel-release-6-5.noarch.rpm"
   end

   desc "common packages"
   task :install_commonpackages, :roles => :cldash  do
      sudo "yum -y -q install screen nginx git-all rpm-build redhat-rpm-config unifdefi readline readline-devel ncurses ncurses-devel gdbm gdbm-devel glibc-devel tcl-devel gcc unzip openssl-devel db4-devel byacc make"
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

   #################################################################
   # cl_dash install all packages
   desc "all tasks to create a cl_dash server"
   task :install, :roles => :cldash  do
      install_epelrepo 
      install_commonpackages 
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


# ringsail server
namespace :ringsail do
   default_run_options[:pty] = true

   desc "install epel repo"
   task :install_epelrepo, :roles => :ringsail do
      sudo "rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm"
   end

   desc "common packages"
   task :install_commonpackages, :roles => :ringsail  do
      sudo "yum -y -q install screen nginx git-all rpm-build redhat-rpm-config unifdefi readline readline-devel ncurses ncurses-devel gdbm gdbm-devel glibc-devel tcl-devel gcc unzip openssl-devel db4-devel byacc make gcc-c++ curl-devel zlib-devel"
   end

   desc "install ruby 1.9.2 (from rpm)"
   task :install_ruby, :roles => :ringsail  do
      upload("./rpms/el5/x86_64/ruby-1.9.2p290-3.x86_64.rpm","/tmp/ruby-1.9.2p290-3.x86_64.rpm", :mode => 0600)
      sudo "yum -y -q --nogpgcheck  localinstall /tmp/ruby-1.9.2p290-3.x86_64.rpm"
      sudo "rm -f /tmp/ruby-1.9.2p290-3.x86_64.rpm" 
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

   #################################################################
   # ringsail install all packages
   desc "all tasks to create a ringsail server"
   task :install, :roles => :ringsail  do
      install_epelrepo 
      install_commonpackages 
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
