#!/bin/sh -e

set -x

echo "Install build system for Ganglia with Riemann support"

apt-get -y clean
apt-get -y update
apt-get -y install language-pack-en
apt-get -y install git curl wget autoconf automake libtool
apt-get -y install libapr1-dev libconfuse-dev librrd-dev
apt-get -y install protobuf-c-compiler libprotobuf-c0-dev
apt-get -y install libcurl4-openssl-dev

# apt-get -y install python-stdeb devscripts

wget http://concurrencykit.org/releases/ck-0.3.5.tar.gz
tar zxvf ck*.tar.gz
cd ck-0.3.5 && ./configure && make && sudo make install

echo "Done!"
