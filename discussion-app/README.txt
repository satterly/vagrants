To get this to work in vagrant...

1. modify /etc/ganglia/gmond.conf
 > remove all the cloud {} and discovery {} sections
 > uncomment udp_send_channel { 127.0.0.1 }

2. modify /etc/ganglia/conf.d/guardian-mgmt.pyconf
 > GmondConf = /etc/ganglia/gmond.conf
