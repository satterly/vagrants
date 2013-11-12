#!/bin/bash

apt-get clean
apt-get update
apt-get -y install autoconf automake libtool ncompress make gcc git libexpat1-dev libapr1-dev libaprutil1-dev libconfuse-dev libpcre3-dev librrd-dev gperf
apt-get -y install libcurl4-openssl-dev
apt-get -y install python-stdeb devscripts

# Automate Ganglia build
#mkdir ~/build
#git clone git://git.code.sf.net/p/git2dist/code ~/build/git2dist

echo "Done!"
