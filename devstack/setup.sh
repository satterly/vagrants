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

# Optionally alter HEAT_REPO to use a fork.
#HEAT_REPO=https://github.com/sjcorbett/heat.git
#HEAT_BRANCH=master

#ENABLED_SERVICES+=,heat,h-api,h-api-cfn,h-api-cw,h-eng
# echo IMAGE_URLS+=",http://fedorapeople.org/groups/heat/prebuilt-jeos-images/F17-i386-cfntools.qcow2,http://fedorapeople.org/groups/heat/prebuilt-jeos-images/F17-x86_64-cfntools.qcow2" >> localrc
echo IMAGE_URLS+=",http://fedorapeople.org/groups/heat/prebuilt-jeos-images/F18-i386-cfntools.qcow2" >> localrc

# Network configuration. HOST_IP should be the same as the IP you used
# for the private network in your Vagrantfile. The combination of
# FLAT_INTERFACE and PUBLIC_INTERFACE indicates that OpenStack should
# bridge network traffic over eth1.
echo HOST_IP=172.16.0.2 >>localrc
echo HOST_IP_IFACE=eth1 >>localrc
echo FLAT_INTERFACE=br100 >>localrc
echo PUBLIC_INTERFACE=eth1 >> localrc
echo FLOATING_RANGE=172.16.0.224/27 >> localrc

echo LOGFILE=stack.sh.log >> localrc
echo SCREEN_LOGDIR=$DEST/logs/screen >> localrc

./tools/create-stack-user.sh
sudo su - stack "cd ~/vagrant/devstack && /stack.sh"
# ./stack.sh
