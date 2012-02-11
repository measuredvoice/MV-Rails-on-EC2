#!/bin/sh
echo insecure >> /root/.curlrc
curl -o /tmp/rvm-installer -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer 
bash -s stable < /tmp/rvm-installer
source /etc/profile.d/rvm.sh
rvm requirements
rm -f /root/.curlrc
