#!/bin/sh -e

#set -x

echo "Install build system for Ganglia with Riemann support"

apt-get -y clean
apt-get -y update
apt-get -y install language-pack-en
apt-get -y install git curl wget autoconf automake libtool
apt-get -y install libapr1-dev libconfuse-dev librrd-dev
apt-get -y install protobuf-compiler protobuf-c-compiler libprotobuf-c0-dev
apt-get -y install libcurl4-openssl-dev

# apt-get -y install python-stdeb devscripts

wget http://concurrencykit.org/releases/ck-0.3.5.tar.gz
tar zxvf ck*.tar.gz
cd ck-0.3.5 && ./configure && make && sudo make install

apt-get -y install openjdk-7-jre
wget -q http://aphyr.com/riemann/riemann-0.2.4.tar.bz2
tar xvfj riemann-*.tar.bz2
cd riemann-*
mkdir /var/log/riemann
nohup bin/riemann etc/riemann.config 2>&1 &

echo "Done!"
