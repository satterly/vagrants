#!/bin/sh

apt-get -y update
apt-get -y install git openjdk-7-jre python-pip ruby-dev
wget http://aphyr.com/riemann/riemann_0.2.5_all.deb
dpkg -i riemann*.deb

gem install --no-rdoc --no-ri riemann-tools
git clone https://github.com/satterly/python-riemann-client.git
cd python-riemann-client
python setup.py install

echo "Done!"

