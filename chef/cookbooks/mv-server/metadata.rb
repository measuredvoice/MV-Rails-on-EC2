name             "mv-server"
maintainer       "Andrew Hollingsworth"
maintainer_email "adh@techopsguru.com"
license          "All rights reserved"
description      "Installs/Configures mv-server"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

depends "yum"
depends "ohai"
depends "build-essential"
depends "percona-install"
depends "nginx"
depends "nodejs"
depends "accounts"
depends 'nagios'
depends 'database'

