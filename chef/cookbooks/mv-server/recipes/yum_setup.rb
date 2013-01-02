# Ensure yum is setup and 
# get epel repo
include_recipe "yum"
include_recipe "yum::epel"

# update all rpms
execute "yum_update" do
   command "yum -y update"
   action :run
end
