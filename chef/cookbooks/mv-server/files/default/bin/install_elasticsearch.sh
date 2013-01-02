#!/bin/sh

cd /opt
curl -s http://cloud.github.com/downloads/elasticsearch/elasticsearch/elasticsearch-0.19.3.tar.gz | tar xvz
ln -s elasticsearch-0.19.3/ elasticsearch
curl -s -k -L http://github.com/elasticsearch/elasticsearch-servicewrapper/tarball/master | tar -xz
mv *servicewrapper*/service elasticsearch/bin/
rm -Rf *servicewrapper*
/opt/elasticsearch/bin/service/elasticsearch install
ln -s `readlink -f elasticsearch/bin/service/elasticsearch` /usr/bin/elasticsearch_ctl
sed -i -e 's|# cluster.name: elasticsearch|cluster.name: graylog2|' /opt/elasticsearch/config/elasticsearch.yml

mkdir /opt/elasticsearch-0.19.3/logs

/etc/init.d/elasticsearch start

exit 0
