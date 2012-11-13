node default {

	class { 'ganglia::client':
		aws_access_key  => '022QF06E7MXBSAMPLE',
		aws_secret_key  => 'kWcrlUX5JEDGM/SAMPLE/aVmYvHNif5zB+d9+ct',
		tags            => '"Stage = PROD", "Role = frontend"',
		security_groups => 'default',
		zones           => 'eu-west-1a',
		host_type       => 'private_ip',
		discover_every  => 120,
		udp_recv_buffer => '10485760'
	}
}
