node default {

	yumrepo { 'nginx-repo':
		baseurl  => 'http://nginx.org/packages/rhel/6/x86_64/',
		gpgcheck => 0
	}
	package { 'nginx': require => Yumrepo['nginx-repo'] }
	service { 'nginx': }

	$repo = 'https://s3-eu-west-1.amazonaws.com/gnl-core-infra-yumrepo-eu-west-1'

	yumrepo { 'local':
		descr           => 'Guardian Local Repository',
		baseurl         => "${repo}/local/el6/\$basearch",
		enabled         => 1,
		gpgcheck        => 0,
		priority        => 2,
		metadata_expire => 300
	}

	# class { 'ganglia::client':
		# aws_access_key  => '022QF06E7MXBSAMPLE',
		# aws_secret_key  => 'kWcrlUX5JEDGM/SAMPLE/aVmYvHNif5zB+d9+ct',
		# tags            => '"Stage = PROD", "Role = frontend"',
		# security_groups => 'default',
		# zones           => 'eu-west-1a',
		# host_type       => 'private_ip',
		# discover_every  => 120,
		# udp_recv_buffer => '10485760'
	# }

	class { 'ganglia::client':
		unicast_ips => $::hostname
	}

	ganglia::client::module { 'guardian-mgmt': }

	logster::parser { 'nginx':
		parser          => 'NginxLogster',
		logfile         => '/var/log/nginx/access.log',
		gmetric_options => '-c /var/lib/ganglia/gmond-cloud.conf'
	}
}
