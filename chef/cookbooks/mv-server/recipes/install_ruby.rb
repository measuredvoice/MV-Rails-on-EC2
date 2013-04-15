# ruby 1.9.3. package from local
cookbook_file "/root/ruby-1.9.3p327-1.el6.x86_64.rpm" do
  mode 0640
  action :create_if_missing
end

package "libyaml" do
  action :install
end

rpm_package "ruby-1.9.3" do
  action :install
  version "1.9.3p327"
  source "/root/ruby-1.9.3p327-1.el6.x86_64.rpm"
end

# update gem 
execute "gem system update" do
  command "/usr/bin/gem update --system"
  action :run
end

# install bundler
gem_package "bundler" do
  action :install
  ignore_failure true
end

