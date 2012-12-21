node default {

	file { '/etc/apt/sources.list':
		source => 'puppet:///modules/site/etc/apt/sources.list'
	}

	package { [
		'ubuntu-dev-tools',
		'build-essential',
		'autoconf',
		'libtool',
		'debhelper',
		'librrd-dev',
		'libapr1-dev',
		'libaprutil1-dev',
		'libconfuse-dev',
		'libcurl4-openssl-dev',
		'libperl-dev',
		'python-dev',
                'git'
	 ]:

		ensure  => latest,
		require => File['/etc/apt/sources.list']
	}
}
