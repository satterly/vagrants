vagrants
========

General
-------

    $ git clone git@github.com:satterly/vagrants.git
    $ cd vagrants
    $ cd <boxname>
    $ vagrant up
    $ vagrant ssh -- -A
    
OpenStack
---------

    $ sudo vagrant plugin install vagrant-openstack-plugin
    $ vagrant box add dummy https://github.com/cloudbau/vagrant-openstack-plugin/raw/master/dummy.box
    $ vagrant up --provider=openstack
    $ vagrant ssh
    
