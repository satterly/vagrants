node default {

	file { '/etc/apt/sources.list':
		source => 'puppet:///modules/site/etc/apt/sources.list'
	}

	package { [
		'debhelper',
		'ubuntu-dev-tools',
		'build-essential',
		'make',
		'autoconf',
		'automake',
		'libtool',
		'libapr1-dev',
		'libconfuse-dev',
		'librrd-dev',
		'protobuf-c-compiler',
		'libprotobuf-c0-dev',
		'git',
	 ]:
		ensure  => latest,
		require => File['/etc/apt/sources.list']
	}
}
