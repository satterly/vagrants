#!/bin/sh

echo "Install build system for Ganglia with Riemann support"

yum install -y git curl wget autoconf automake libtool
yum install -y apr-devel libconfuse-devel rrdtool-devel expat-devel pcre-devel

wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -Uvh epel-release-6-8.noarch.rpm
yum install -y protobuf-compiler protobuf-c-devel

cd ~
yum install -y rpmdevtools
rpmdev-setuptree
pushd rpmbuild/SOURCES
wget http://concurrencykit.org/releases/ck-0.4.tar.gz
popd
pushd rpmbuild/SPECS
wget http://concurrencykit.org/releases/ck-0.4.spec
rpmbuild -bb ck-0.4.spec
popd
rpm -Uvh rpmbuild/RPMS/x86_64/ck*-0.4-1.el6.x86_64.rpm

yum install -y java-1.7.0-openjdk
wget -q http://aphyr.com/riemann/riemann-0.2.4.tar.bz2
tar xvfj riemann-*.tar.bz2
cd riemann-*
mkdir /var/log/riemann
nohup bin/riemann etc/riemann.config 2>&1 &

echo "Done!"
