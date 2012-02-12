#################################################################
# Capistrano capfile for setup of servers for
# Measured Voice cl_dash sercers
#
# adh - 20120210
#
# Requires user with sudo access on CentOS 5.x ot RHEL 5.x


#################################################################
# Define servers
server "ec2-50-19-10-251.compute-1.amazonaws.com", :cldash
server "ec2-174-129-118-37.compute-1.amazonaws.com", :ringsail


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
      sudo "yum -y -q install screen nginx git-all"
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
      sudo "yum -y -q install Percona-Server-shared-compat.x86_64 Percona-Server-client-55 Percona-Server-server-55" 
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
   end
end


# ringsail server
namespace :ringsail do
   default_run_options[:pty] = true

   desc "install epel repo"
   task :install_epelrepo, :roles => :ringsail do
      sudo "rpm -Uvh http://download.fedora.redhat.com/pub/epel/6/x86_64/epel-release-6-5.noarch.rpm"
   end

   desc "common packages"
   task :install_commonpackages, :roles => :ringsail  do
      sudo "yum -y -q install screen git-all gcc-c++ curl-devel zlib-devel httpd-devel apr-devel apr-util-devel"
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
      sudo "yum -y -q install Percona-Server-shared-compat.x86_64 Percona-Server-client-55 Percona-Server-server-55" 
      upload("./etc/my.cnf.ringsail","/tmp/my.cnf.ringsail", :mode => 0644)
      sudo "cp /tmp/my.cnf.ringsail /etc"
      #sudo "mv -f /etc/my.cnf /etc/my.cnf.orig"
      sudo "ln -s /etc/my.cnf.ringsail /etc/my.cnf"
      sudo "rm -f /tmp/my.cnf.ringsail"
      sudo "/etc/init.d/mysql start"
      sudo "/sbin/chkconfig mysql on"
      sudo "/usr/bin/mysqladmin -u root password ringsail2012"
      upload("./etc/.my.cnf.ringsail.root","/tmp/.my.cnf.ringsail.root", :mode => 0600)
      sudo "cp -pf /tmp/.my.cnf.ringsail.root /root/.my.cnf" 
      sudo "rm -f /tmp/.my.cnf.ringsail.root"
   end

   desc "install latest Apache"
   task :install_apache, :roles => :ringsail do
      sudo "yum -y install httpd"
   end

   desc "install Phusion Passenger"
   task :install_passenger, :roles => :ringsail do
      sudo "gem install passenger"
      sudo "passenger-install-apache2-module --auto"
   end

   #################################################################
   # ringsail install all packages
   desc "all tasks to create a ringsail server"
   task :install, :roles => :ringsail  do
      install_epelrepo 
      install_commonpackages 
      install_percona
      install_ruby
      update_gem
      install_bundler
   end
end
