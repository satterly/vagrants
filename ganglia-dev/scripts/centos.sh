#!/bin/sh -e

#set -x

echo "Install build system for Ganglia with Riemann support"

yum install autoconf automake libtool
yum install apr-devel libconfuse-devel rrdtool-devel expat-devel pcre-devel
yum install protobuf-compiler protobuf-c-devel

wget http://concurrencykit.org/releases/ck-0.3.5.tar.gz
tar zxvf ck*.tar.gz
cd ck-0.3.5 && ./configure && make && sudo make install

yum install java-1.7.0-openjdk
wget -q http://aphyr.com/riemann/riemann-0.2.4.tar.bz2
tar xvfj riemann-*.tar.bz2
cd riemann-*
mkdir /var/log/riemann
nohup bin/riemann etc/riemann.config 2>&1 &

echo "Done!"
