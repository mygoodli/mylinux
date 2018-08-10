#!/bin/bash


for i in $1
do
virsh destroy $i &>/dev/null
virsh undefine $i &>/dev/null
rm -fr /var/lib/libvirt/images/$i.*
done

