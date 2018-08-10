#!/bin/bash


read -p "plase input your kvm name:" NAME

virt-clone -o r6_base -n $NAME -f /var/lib/libvirt/images/$NAME.img &>/dev/null
sed -i "s/domain-r6_base/domain-$NAME/" /etc/libvirt/qemu/$NAME.xml &>/dev/null
virsh define /etc/libvirt/qemu/$NAME.xml &>/dev/null



