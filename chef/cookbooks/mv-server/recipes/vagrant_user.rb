# ensure vagrant user is OK

account "vagrant" do
   uid "501"
   account_type "role"
   password "!!"
   comment ""
   ssh true
end

