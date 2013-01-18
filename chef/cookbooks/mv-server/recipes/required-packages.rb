for pkg in [ 'libxml2',
             'screen',
             'git-all',
             'rpm-build',
             'redhat-rpm-config',
             'unifdef',
             'readline',
             'readline-devel',
             'ncurses',
             'ncurses-devel',
             'gdbm',
             'gdbm-devel',
             'glibc-devel',
             'tcl-devel',
             'gcc',
             'unzip',
             'openssl-devel',
             'db4-devel',
             'byacc',
             'make',
             'ImageMagick',
             'libxml2-devel',
             'libxslt-devel',
             'memcached',
             'gcc-c++',
             'crontabs',
             'ntpdate'
] do
   package "#{pkg}" do
      action :install
   end
end

service "memcached" do
  supports :restart => true, :status => true
  action [ :enable, :start ]
end
