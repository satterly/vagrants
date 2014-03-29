#!/bin/sh

wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -Uvh epel-release-6-8.noarch.rpm

yum -y install wget git rpm-build rpmdevtools
yum -y install python-devel python-setuptools python-virtualenv
yum -y install httpd mod_wsgi mongodb mongodb-server rabbitmq-server

rpmdev-setuptree
version=$(<VERSION)

rm -Rf alerta-${version}
git clone https://github.com/guardian/alerta.git alerta-${version}
pushd alerta-${version}
git archive --format=tar --prefix="alerta-${version}/" HEAD | gzip > ~/rpmbuild/SOURCES/alerta-${version}.tar.gz
popd

rm -Rf alerta-client-${version}
git clone https://github.com/alerta/python-alerta-client.git alerta-client-${version}
pushd alerta-client-${version}
git archive --format=tar --prefix="alerta-client-${version}/" HEAD | gzip > ~/rpmbuild/SOURCES/alerta-client-${version}.tar.gz
popd

sudo service mongod start
sudo service rabbitmq-server start
sudo alerta -f --debug --use-stderr

