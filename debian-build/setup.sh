#!/bin/bash

apt-get -y install autoconf automake libtool ncompress make gcc git libexpat1-dev libapr1-dev libconfuse-dev libpcre3-dev rrdtool-dev gperf

mkdir ~/build
git clone git://git.code.sf.net/p/git2dist/code ~/build/git2dist

echo "Done!"
