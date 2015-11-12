#!/bin/bash -e

set -x

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
pushd ck-0.3.5 && ./configure && make && sudo make install
popd

git clone https://github.com/ganglia/monitor-core.git
pushd monitor-core
./bootstrap
./configure --with-gmetad --with-riemann
make
sudo make install
popd

apt-get -y install openjdk-7-jre python-pip
pushd /var/tmp
wget http://aphyr.com/riemann/riemann_0.2.5_all.deb
dpkg -i riemann_0.2.5_all.deb
service riemann start
popd

pushd /tmp
git clone https://github.com/satterly/python-riemann-client.git
pushd python-riemann-client
python setup.py install
popd
popd

echo "Done!"
