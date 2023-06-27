terraform {
  required_version = ">= 0.15.0"
}

terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "2.11.0"
    }
  }
}

resource "docker_network" "network" {
  # (resource arguments)
}

resource "docker_volume" "nginx" {
  # (resource arguments)
}

resource "docker_container" "nginx" {
  # (resource arguments)
}


Multicast Source 

#!/bin/bash -xe
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum-config-manager --enable epel
yum update -y
yum upgrade -y
yum install -y autoconf automake gcc git iperf
yum clean all
rm -rf /var/cache/yum
echo '# Force IGMPv2 for AWS Transit Gateway' > /etc/sysctl.d/01-multicast.conf
echo 'net.ipv4.conf.eth0.force_igmp_version = 2' >> /etc/sysctl.d/01-multicast.conf
wget -O /usr/bin/mcast_app https://svn.python.org/projects/python/trunk/Demo/sockets/mcast.py
chmod 755 /usr/bin/mcast_app
sed -i 's/MYTTL = 1/MYTTL = 32/g' /usr/bin/mcast_app
sed -i 's/225.0.0.250/${MulticastGroup}/g' /usr/bin/mcast_app
git clone https://github.com/troglobit/mcjoin.git /tmp/mcjoin
cd /tmp/mcjoin
./autogen.sh
./configure && make
make install-strip
cd /tmp
rm -rf ./*
reboot

Multicast member 1
#!/bin/bash -xe
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum-config-manager --enable epel
yum update -y
yum upgrade -y
yum install -y autoconf automake gcc git iperf
yum clean all
rm -rf /var/cache/yum
echo '# Force IGMPv2 for AWS Transit Gateway' > /etc/sysctl.d/01-multicast.conf
echo 'net.ipv4.conf.eth0.force_igmp_version = 2' >> /etc/sysctl.d/01-multicast.conf
wget -O /usr/bin/mcast_app https://svn.python.org/projects/python/trunk/Demo/sockets/mcast.py
chmod 755 /usr/bin/mcast_app
sed -i 's/MYTTL = 1/MYTTL = 32/g' /usr/bin/mcast_app
sed -i 's/225.0.0.250/${MulticastGroup}/g' /usr/bin/mcast_app
git clone https://github.com/troglobit/mcjoin.git /tmp/mcjoin
cd /tmp/mcjoin
./autogen.sh
./configure && make
make install-strip
cd /tmp
rm -rf ./*
reboot

Multicast Member 2

#!/bin/bash -xe
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum-config-manager --enable epel
yum update -y
yum upgrade -y
yum install -y autoconf automake gcc git iperf
yum clean all
rm -rf /var/cache/yum
echo '# Force IGMPv2 for AWS Transit Gateway' > /etc/sysctl.d/01-multicast.conf
echo 'net.ipv4.conf.eth0.force_igmp_version = 2' >> /etc/sysctl.d/01-multicast.conf
wget -O /usr/bin/mcast_app https://svn.python.org/projects/python/trunk/Demo/sockets/mcast.py
chmod 755 /usr/bin/mcast_app
sed -i 's/MYTTL = 1/MYTTL = 32/g' /usr/bin/mcast_app
sed -i 's/225.0.0.250/${MulticastGroup}/g' /usr/bin/mcast_app
git clone https://github.com/troglobit/mcjoin.git /tmp/mcjoin
cd /tmp/mcjoin
./autogen.sh
./configure && make
make install-strip
cd /tmp
rm -rf ./*
reboot