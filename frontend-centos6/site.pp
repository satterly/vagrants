class yum {

	$repo = 'https://s3-eu-west-1.amazonaws.com/gnl-core-infra-yumrepo-eu-west-1'

	yumrepo { 'frontend':
		descr           => 'Frontend Repository',
		baseurl         => "${repo}/devstack/frontend/el6/\$basearch",
		enabled         => 1,
		gpgcheck        => 0,
		priority        => 1,
		metadata_expire => 300
	}

	yumrepo { 'local':
		descr           => 'Guardian Local Repository',
		baseurl         => "${repo}/local/el6/\$basearch",
		enabled         => 1,
		gpgcheck        => 0,
		priority        => 2,
		metadata_expire => 300
	}

	yumrepo { 'nginx':
		descr           => 'NGINX Repository Mirror',
		baseurl         => "${repo}/nginx/centos/6/\$basearch",
		enabled         => 1,
		gpgcheck        => 0,
		priority        => 3,
		metadata_expire => 300
	}

	yumrepo { 'epel':
		descr           => 'EPEL Repository Mirror',
		baseurl         => "${repo}/epel/6/\$basearch",
		enabled         => 1,
		gpgcheck        => 0,
		priority        => 4,
		metadata_expire => 300
	}
}

class vagrant {

	exec { '/sbin/iptables --flush': }

	package { 'cronie': ensure => latest; }

	site::sudo::entry { 'vagrant':
		sudo_user      => vagrant,
		cmd_alias_name => 'VAGRANT',
		cmd_list       => ['ALL'],
		sudoexec       => true,
		defaults       => ['!logfile', '!requiretty', 'syslog_goodpri=debug']
	}
}

class frontend {

	package { 'nginx': }
	service { 'nginx': }

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

node default {

	stage { 'preinstall': } -> Stage[main] -> stage { 'late': }

	class { yum: stage => 'preinstall' }
	class { vagrant: }
	class { frontend: }
}
