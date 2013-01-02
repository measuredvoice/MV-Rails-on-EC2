# using accounts cookbook LWRPs

# add user accounts
account "adh" do
   uid "11001"
   account_type "user"
   password "$1$fCZgN0Np$OB8I9IWwVY/pHVbN7Bw/.1"
   comment "Andrew Hollingsworth"
   ssh true
   sudo true
end

account "chris" do
   uid "33002"
   account_type "user"
   password "!!"
   comment "Chris Radcliff"
   ssh true
   sudo true
end

# add role accounts
account "mv" do
   uid "33001"
   account_type "role"
   password "!!"
   comment "Measured Voice Deploy"
   ssh true
   sudo false
end


# sudoers (must come after account definitions)
template "/etc/sudoers" do
  source "sudoers.erb"
  mode 0440
  owner "root"
  group "root"
  variables(
    :sudoers_groups => node[:accounts][:sudo][:groups], 
    :sudoers_users => node[:accounts][:sudo][:users]
  )
end
