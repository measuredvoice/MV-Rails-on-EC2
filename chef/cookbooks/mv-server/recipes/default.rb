#
# Cookbook Name:: mv-server
# Recipe:: default
#
# Copyright (C) 2012 YOUR_NAME
# 
# All rights reserved - Do Not Redistribute
#

if Chef::Config[:solo]
   Chef::Config[:data_bag_path] = "data_bags"
end

# setup yum
include_recipe "mv-server::yum_setup"

# create users
include_recipe "mv-server::users"

# install build essential
include_recipe "build-essential"

# packages
include_recipe "mv-server::required-packages"

# crontabs
include_recipe "mv-server::crons"

# install a default nagios client
include_recipe "mv-server::nagios_client"

