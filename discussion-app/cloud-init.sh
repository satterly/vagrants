#!/bin/bash

rpm -Uv http://dl.fedoraproject.org/pub/epel/6/x86_64/redis-2.4.10-1.el6.x86_64.rpm
service redis start

mkdir /etc/gu

cat > /etc/gu/ganglia-init.conf << EOF
AWSAccessKeyId=022QF06E7MXBSAMPLE
AWSSecretKey=kWcrlUX5JEDGM/SAMPLE/aVmYvHNif5zB+d9+ct
ServerRole=discussion-app
FilterByTags="'elasticbeanstalk:environment-name=discussion-app-code-env'"
FilterByGroups=
FilterByZones=
EOF

wget -qO- https://ec2-monitoring.s3-eu-west-1.amazonaws.com/ganglia/ganglia-init.sh | bash
