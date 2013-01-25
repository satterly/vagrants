class yum {

	# $repo = 'https://s3-eu-west-1.amazonaws.com/gnl-core-infra-yumrepo-eu-west-1'
	$repo = 'http://yum.gudev.gnl/yum-repo'

	yumrepo { 'centos':
		descr           => 'CentOS-$releasever - Base',
		baseurl         => "${repo}/centos/6.2/os/\$basearch",
		enabled         => 1,
		gpgcheck        => 0,
		gpgkey          => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6",
		metadata_expire => 300
	}

	yumrepo { 'local':
		descr           => 'Guardian Local Repository',
		baseurl         => "${repo}/local/el6/\$basearch",
		enabled         => 1,
		gpgcheck        => 0,
		metadata_expire => 300
	}

	yumrepo { 'rpmforge':
		descr           => 'RHEL RPMforge.net Repository',
		baseurl         => "${repo}/rpmforge/redhat/el6/en/\$basearch/rpmforge",
		enabled         => 1,
		gpgcheck        => 1,
		gpgkey          => "${repo}/rpmforge/RPM-GPG-KEY-rpmforge-dag",
		metadata_expire => 300
	}

	yumrepo { 'rpmforge-extras':
		descr           => 'RHEL RPMforge.net Repository Extras',
		baseurl         => "${repo}/rpmforge/redhat/el6/en/\$basearch/extras",
		enabled         => 1,
		gpgcheck        => 1,
		gpgkey          => "${repo}/rpmforge/RPM-GPG-KEY-rpmforge-dag",
		metadata_expire => 300
	}

	yumrepo { 'epel':
		descr           => 'EPEL Repository Mirror',
		baseurl         => "${repo}/epel/6/\$basearch",
		enabled         => 1,
		gpgcheck        => 0,
		metadata_expire => 300
	}

	yumrepo { '10gen':
		descr           => '10gen Repository',
		baseurl         => "${repo}/10gen/redhat/os/\$basearch",
		enabled         => 1,
		gpgcheck        => 0,
		priority        => 4,
		metadata_expire => 300
	}
}

class preinstall {

	file { '/etc/sysconfig/clock':
		content => 'ZONE="Europe/London"'
	}

	file { '/etc/localtime':
		ensure => 'link',
		target => '/usr/share/zoneinfo/Europe/London'
	}

	exec { '/usr/sbin/ntpdate pool.ntp.org':
		require => [ File['/etc/sysconfig/clock'], File['/etc/localtime'] ]
	}

	exec { '/sbin/iptables --flush': }

}

class sudofix {
	file_line { 'vagrant_sudo':
		path => '/etc/sudoers',
		line => 'vagrant        ALL=(ALL)       NOPASSWD: ALL',
	}
}

class monitoring {

	# class { 'fitb':
		# mysql_root_password => '4tyWvnxRaa07nUVj1b3Q', # used pwgen --secure -N 1 20
		# fitb_db_password    => 'nguzpQwDYF8nZqpnXwo4',
		# config_include_glob => '/etc/fitb/conf.d/snmp*.php'
	# }

	# include alerta
	include ganglia::server

	ganglia::server::grid { 'PROD':
		# data_sources     => {
			# "R2" => "respub01 respub02",
			# "Discussion" => "dispub01 dispub02",
		# },
		xml_port         => 12101,
		interactive_port => 12102,
	}
	ganglia::server::grid { 'DEV':
		data_sources     => {
			"CODE R2" => "codrespub01 coderespub02",
			"CODE Discussion" => "coddispub01 dispub02",
			"STAGE Discussion" => "stgdispub01 dispub02",
			"DEV Discussion" => "devdispub01 dispub02",
			"LWP Discussion" => "lwpdispub01 dispub02",
		},
		xml_port         => 12201,
		interactive_port => 12202,
	}
	ganglia::server::grid { 'INFRA':
		data_sources     => {
			"Servers" => "localhost:12311",
		},
		xml_port         => 12301,
		interactive_port => 12302,
	}
	ganglia::server::grid { 'INFRA-Servers':
		data_sources     => {
			"monitoring" => "devmonsvr01.gudev.gnl",
			"test" => "localhost",
		},
		xml_port         => 12311,
		interactive_port => 12312,
	}
	# include ganglia::client

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

	# ganglia::collector { 'zeus': send_recv_port => 9001 }
	# ganglia::client::module { 'zxtm': collector => 'zeus' }
}

node default {

	stage { 'start': } -> Stage[main] -> stage { 'end': }

	class { yum: stage => 'start' }
	class { preinstall: stage => 'start' }
	class { monitoring: }
	class { sudofix: stage => 'end' }
}
