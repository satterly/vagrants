node default {
        $role = 'respub'

        class { 'ganglia::client':
                udp_recv_buffer => '10485760'
        }

        ganglia::client::module { 'guardian-mgmt':
                applications => 'respub',
                urls         => 'http://localhost:8080/r2frontend'
        }

        # class { 'common': }
        # include common_linux

        # networking::linux_bond { 'bond0': }

        # include nodes_mount

        # include respub_server

        # include common_foglight
        # include antivirus

        # include memcached_r2_instance
}
