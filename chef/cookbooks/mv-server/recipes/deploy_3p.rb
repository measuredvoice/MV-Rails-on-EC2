# branches by environment
branch_name = case node.chef_environment
   when "prod" then "master"
   when "staging" then "staging"
   else "develop"
end

# brnaches by hostname

