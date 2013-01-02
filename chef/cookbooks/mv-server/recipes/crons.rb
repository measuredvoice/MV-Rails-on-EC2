################################################################
# cron jobs to run

# run ntpdate to ensure time is really correct
# 21 * * * *       root    /usr/sbin/ntpdate time.apple.com >/dev/null 2>&1 
cron "ntpdate" do
   minute "21"
   command "/usr/sbin/ntpdate -s time.apple.com"
end

