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

mkdir /var/run/ports/
echo "80" >/var/run/ports/discussion-app.port

yum -y install httpd
service httpd start

mkdir /var/www/html/management
cat > /var/www/html/management/status << EOF
{"metrics": [{"count": 8717, "totalTime": 77954, "group": "application", "description": "HTTP requests to the application", "title": "Http Requests", "type": "timer", "name": "http-requests"}, {"count": 0, "group": "application", "description": "The number of 5XX errors returned by the application", "title": "Server Errors", "type": "counter", "name": "server-error"}, {"count": 1, "group": "application", "description": "Counts the number of uncaught exceptions being sent to the client from the application", "title": "Exception Count", "type": "counter", "name": "exception-count"}, {"count": 109, "group": "application", "description": "The number of 4XX errors returned by the application", "title": "Client Errors", "type": "counter", "name": "client-error"}, {"count": 8627, "totalTime": 27342, "group": "endpoints", "description": "index", "title": "index", "type": "timer", "name": "index"}, {"count": 3, "totalTime": 3, "group": "endpoints", "description": "preferences", "title": "preferences", "type": "timer", "name": "preferences"}, {"count": 64, "totalTime": 40081, "group": "endpoints", "description": "discussion", "title": "discussion", "type": "timer", "name": "discussion"}, {"count": 2, "totalTime": 3498, "group": "endpoints", "description": "post_comment_form", "title": "post_comment_form", "type": "timer", "name": "post_comment_form"}, {"count": 1, "totalTime": 13, "group": "endpoints", "description": "get_discussion_for_key", "title": "get_discussion_for_key", "type": "timer", "name": "get_discussion_for_key"}, {"count": 1, "totalTime": 3595, "group": "endpoints", "description": "js_user_metadata", "title": "js_user_metadata", "type": "timer", "name": "js_user_metadata"}, {"count": 3, "totalTime": 1120, "group": "endpoints", "description": "api_proxy", "title": "api_proxy", "type": "timer", "name": "api_proxy"}, {"count": 16, "totalTime": 2302, "group": "endpoints", "description": "get_user_actions", "title": "get_user_actions", "type": "timer", "name": "get_user_actions"}], "application": "DiscussionApp", "time": 1353072009540}
EOF

wget -qO- https://ec2-monitoring.s3-eu-west-1.amazonaws.com/ganglia/ganglia-init.sh | bash
