class yum {

	$repo = 'https://s3-eu-west-1.amazonaws.com/gnl-core-infra-yumrepo-eu-west-1'

	yumrepo { 'local':
		descr           => 'Guardian Local Repository',
		baseurl         => "${repo}/local/el6/\$basearch",
		enabled         => 1,
		gpgcheck        => 0,
		priority        => 2,
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

class monitoring {

	# class { 'fitb':
		# mysql_root_password => '4tyWvnxRaa07nUVj1b3Q',
		# fitb_db_password    => 'nguzpQwDYF8nZqpnXwo4',
		# config_include_glob => '/etc/fitb/conf.d/snmp*.php'
	# }

	include alerta
}

node default {

	stage { 'start': } -> Stage[main] -> stage { 'end': }

	class { yum: stage => 'start' }
	class { preinstall: stage => 'start' }
	class { monitoring: }
}
