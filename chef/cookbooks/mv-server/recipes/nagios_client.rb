# nrpe setup
package "nrpe"
package "nagios-plugins-disk"

cookbook_file "/etc/nagios/nrpe.cfg" do
   source "nagios/nrpe.cfg"
   owner "root"
   group "root"
   mode 00640
   notifies :reload, "service[nrpe]"
end

service "nrpe" do
  supports :restart => true, :status => true
  action [ :enable, :start ]
end

