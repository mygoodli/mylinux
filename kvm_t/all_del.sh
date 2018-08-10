#!/bin/bash


for i in $(virsh list --all |awk 'NR>2 {print $2}' |grep -v ^$ |grep -v sys)
do
virsh destroy $i &>/dev/null
virsh undefine $i &>/dev/null
rm -fr /var/lib/libvirt/images/$i.*
done

