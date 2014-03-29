#!/bin/sh -e

set -x

echo "Install build system for Ganglia with Riemann support"

apt-get -y clean
apt-get -y update
apt-get -y install git curl wget autoconf automake libtool
apt-get -y install libapr1-dev libconfuse-dev librrd-dev
apt-get -y install protobuf-compiler protobuf-c-compiler libprotobuf-c0-dev
apt-get -y install libcurl4-openssl-dev

# apt-get -y install python-stdeb devscripts

test ! -f ck-0.3.5.tar.gz && wget http://concurrencykit.org/releases/ck-0.3.5.tar.gz
tar zxvf ck*.tar.gz
test ! -d ck-0.3.5 && pushd ck-0.3.5 && ./configure && make && sudo make install && popd

apt-get -y install openjdk-7-jre
test ! -f riemann-0.2.4.tar.bz2 && wget -q http://aphyr.com/riemann/riemann-0.2.4.tar.bz2
tar xvfj riemann-0.2.4.tar.bz2
test ! -d /var/log/riemann && mkdir /var/log/riemann
echo `pwd`
pushd riemann-0.2.4
nohup bin/riemann etc/riemann.config 2>&1 &
popd

git clone -b release/3.7 https://github.com/ganglia/monitor-core.git ganglia-3.7.0
pushd ganglia-3.7.0
./bootstrap
./configure --with-gmetad --enable-perl \
            --enable-php --enable-status --with-python \
            --with-riemann
make dist
popd

echo "Done!"
