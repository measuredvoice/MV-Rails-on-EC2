#
# Cookbook Name:: accounts
# Attributes:: accounts
#
# Copyright 2009, Alexander van Zoest
#
# global settings
default[:accounts][:dir] = "/home"
default[:accounts][:cookbook] = "accounts"
# default settings
default[:accounts][:default][:shell] = "/bin/bash"
default[:accounts][:default][:file_backup] = 2
default[:accounts][:default][:group] = "users"
default[:accounts][:default][:do_ssh] = false
default[:accounts][:default][:do_sudo] = false
# sudo access management
default[:accounts][:sudo][:groups] = []
default[:accounts][:sudo][:users] = []
