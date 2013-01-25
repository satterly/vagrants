node default {

	file { '/etc/apt/sources.list':
		source => 'puppet:///modules/site/etc/apt/sources.list'
	}

	package { [
		'debhelper',
		'ubuntu-dev-tools',
		'build-essential',
	x	'autoconf',
	x	'automake',
	x	'libtool',
	x	'ncompress',
	x	'make',
	x	'gcc',
	x	'git',
	x	'libexpat1-dev',
	x	'libapr1-dev',
	x	'libaprutil1-dev',
	x	'libconfuse-dev',
		'libperl-dev',
	x	'libpcre3-dev',
	x	'rrdtool',
	x	'librrd-dev',
	x	'gperf',
	x	'libcurl4-openssl-dev',
	x	'python-dev',
	x	'libdbi0-dev'
	 ]:

		ensure  => latest,
		require => File['/etc/apt/sources.list']
	}
}
