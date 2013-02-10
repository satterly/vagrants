#!/bin/sh
apt-get update
apt-get install -qqy git
git clone https://github.com/openstack-dev/devstack.git
cd devstack
echo ADMIN_PASSWORD=password > localrc
echo MYSQL_PASSWORD=password >> localrc
echo RABBIT_PASSWORD=password >> localrc
echo SERVICE_PASSWORD=password >> localrc
echo SERVICE_TOKEN=tokentoken >> localrc
./stack.sh
