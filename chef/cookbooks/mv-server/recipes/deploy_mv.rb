# home directory
apphome = "/home/mv/mv2app"

# brnaches by hostname 
branch_name = case node.hostname
   when "genua"  then "staging"
   when "omnia"  then "develop"
   when "omnia2"  then "develop"
end

# branches by environment if not defined by hostname
branch_name ||= case node.chef_environment
   when "prod" then "master"
   when "staging" then "staging"
   else "develop"
end

# capistrano multistage compatibility
multistage = case branch_name
   when "develop" then "dev"
   else branch_name
end

# create directories if they do not exist
for dir in [ "#{apphome}",
             "#{apphome}/cap",
             "#{apphome}/cap/releases",
             "#{apphome}/cap/shared",
             "#{apphome}/cap/shared/assets",
             "#{apphome}/cap/shared/bundle",
             "#{apphome}/cap/shared/cached-copy",
             "#{apphome}/cap/shared/config",
             "#{apphome}/cap/shared/log",
             "#{apphome}/cap/shared/pids",
] do
   directory "#{dir}" do
      mode "0775"
      owner "mv"
      group "users"
      action :create
      recursive true
   end
end

# Define deploy tasks
deploy "#{apphome}/cap" do
   repo "git@github.com:measuredvoice/measured_voice.git"
   revision branch_name
   create_dirs_before_symlink
   shallow_clone true

   before_migrate do 
      # bundler
      current_release_directory = release_path
      running_deploy_user = new_resource.user
      bundler_depot = new_resource.shared_path + '/bundle'
      excluded_groups = %w(development test)

      script 'Bundling the gems' do
        interpreter 'bash'
        cwd current_release_directory
        user running_deploy_user
        code <<-EOS
          bundle install --quiet --deployment --path #{bundler_depot} \
            --without #{excluded_groups.join(' ')} 
          cp #{release_path}/config/files/#{multistage}/database.yml #{apphome}/cap/shared/config
          cp #{release_path}/config/files/#{multistage}/memcached.yml #{apphome}/cap/shared/config
          cp #{release_path}/config/files/#{multistage}/too_many_secrets.rb #{apphome}/cap/shared/config
          crontab config/files/#{multistage}/crontab.txt
        EOS
        # This is the hack used for development of deploy
        ## code <<-EOS
        ##   rm -f #{release_path}/Gemfile.lock 
        ##   bundle install --quiet --no-deployment --path #{bundler_depot} \
        ##     --without #{excluded_groups.join(' ')} 
        ##   cp #{release_path}/config/files/#{multistage}/database.yml #{apphome}/cap/shared/config
        ##   cp #{release_path}/config/files/#{multistage}/memcached.yml #{apphome}/cap/shared/config
        ##   cp #{release_path}/config/files/#{multistage}/too_many_secrets.rb #{apphome}/cap/shared/config
        ##   crontab config/files/#{multistage}/crontab.txt
        ## EOS
          #./script/post_update.sh #{multistage}
      end

      script 'Assets precompile' do
        interpreter 'bash'
        cwd current_release_directory
        user running_deploy_user
        code <<-EOS
          ln -s #{apphome}/cap/shared/assets #{release_path}/public/assets
          bundle exec rake assets:precompile
        EOS
      end
   end
  
   symlinks "config/memcached.yml" => "config/memcached.yml",
            "config/too_many_secrets.rb" => "config/too_many_secrets.rb",
            "log" => "log",
            "pids" => "pids"

   migrate true
   migration_command "bundle exec rake db:migrate"
   environment "RAILS_ENV" => "production"
   user "mv"
   action :deploy # or :rollback
   restart_command "/home/mv/mv2app/cap/current/script/unicorn_exec restart"
end

# unicorn init script
link "/etc/init.d/unicorn_mv2app" do
   to "#{apphome}/cap/current/script/unicorn_mv2app"
end

service "unicorn_mv2app" do
  supports :restart => true, :status => true
  action [ :enable ]
end


