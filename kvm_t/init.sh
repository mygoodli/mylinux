#!/bin/bash

cat > /etc/hosts <<EOT
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.0.101 vm01.uplooking.com vm01
192.168.0.102 vm02.uplooking.com vm02
192.168.0.103 vm03.uplooking.com vm03
192.168.0.104 vm04.uplooking.com vm04
192.168.0.105 vm05.uplooking.com vm05
192.168.0.106 vm06.uplooking.com vm06
192.168.0.107 vm07.uplooking.com vm07
192.168.0.108 vm08.uplooking.com vm08
192.168.0.109 vm09.uplooking.com vm09
192.168.0.110 vm10.uplooking.com vm10
192.168.0.111 vm11.uplooking.com vm11
192.168.0.112 vm12.uplooking.com vm12
192.168.0.113 vm13.uplooking.com vm13
192.168.0.114 vm14.uplooking.com vm14
192.168.0.115 vm15.uplooking.com vm15
192.168.0.116 vm16.uplooking.com vm16
192.168.0.117 vm17.uplooking.com vm17
192.168.0.118 vm18.uplooking.com vm18
192.168.0.119 vm19.uplooking.com vm19
192.168.0.120 vm20.uplooking.com vm20
EOT


Host1=$(grep $1 /etc/hosts |awk '{print $2}')
cat > /etc/sysconfig/network <<EOT
NETWORKING=yes
HOSTNAME=$Host1
EOT

IP1=$(grep $1 /etc/hosts |awk '{print $1}')
cat > /etc/sysconfig/network-scripts/ifcfg-eth0  << EOT
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=none
IPADDR=$IP1
NETMASK=255.255.255.0
GATEWAY=192.168.0.254
EOT

IP2=$(grep $1 /etc/hosts |awk -F'[. ]' '{print $4}')
cat > /etc/sysconfig/network-scripts/ifcfg-eth1  << EOT
DEVICE=eth1
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=none
IPADDR=192.168.100.$IP2
NETMASK=255.255.255.0
EOT

service network restart



mkdir -p /root/.ssh/
echo "sh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtBgbKcXxqyIOwSbKaayZ9owMcXFvcB2ZOys9I3dGlcVYwV+MWjNp/yWF3sUIpWb+NsnRY4C4XNgCjOI8MC5rnpdf32O4XJrbSkdqkEZLGoxoBi+zLu2E16xMlSt9hcnZJEjW9u34iS0NXJuonh6ma+fx7snQc0UithJw/Mfb/bWT6zFtdxbrKJi+db7TTmwB7Au9ijeJn8ZHF4U0PgGHbbPR7KHQxjn1ci2syTNDBCfwM+NO3mB1rqZFyPPfmconSXybB5zVphJX2rOcADLht8lM/1hD2SEhihmJFpmJxK3+9v6YBTeKm1sMoZjWR25/yzJVBOirS4myredGHLUQL root@localhost.localdomain"
 >> /root/.ssh/authorized_keys
