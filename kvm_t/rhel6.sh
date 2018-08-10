#!/bin/bash
#kvm manager
images_dir=/var/lib/libvirt/images
xml_dir=/etc/libvirt/qemu
red_col="\e[1;31m"
blue_col="\e[1;34m"
reset_col="\e[0m"
rhel6_base_img=r6_base-2.qcow2
#rhel7_base_img=rhel7u2_sys.qcow2


rhel6 ()
{
	read -p "请输入创建虚拟机的数量:" vm_num

        for i in `seq $vm_num`
        do
                vm_name=vm${i}
		vm_uuid=$(uuidgen)   
		vm_mac1="52:54:$(dd if=/dev/urandom count=1 2>/dev/null | md5sum | sed -r 's/^(..)(..)(..)(..).*$/\1:\2:\3:\4/')"
		vm_mac2="52:54:$(dd if=/dev/urandom count=1 2>/dev/null | md5sum | sed -r 's/^(..)(..)(..)(..).*$/\1:\2:\3:\4/')"
		vm_img=$images_dir/${vm_name}.qcow2
#删除镜像
		rm -rf $vm_img

                qemu-img create -f qcow2 -b $images_dir/$rhel6_base_img $vm_img &>/dev/null 
		cp -rf /opt/r6_tmeplate.xml /tmp/${vm_name}.xml  &>/dev/null
		sed -ri "s/vm_name/$vm_name/" /tmp/${vm_name}.xml &>/dev/null
		sed -ri "s/vm_uuid/$vm_uuid/" /tmp/${vm_name}.xml &>/dev/null
		sed -ri "s/vm_mac1/$vm_mac1/" /tmp/${vm_name}.xml &>/dev/null
                sed -ri "s/vm_mac2/$vm_mac2/" /tmp/${vm_name}.xml &>/dev/null
		sed -ri "s#vm_disk#$vm_img#" /tmp/${vm_name}.xml &>/dev/null
		sed -ri "s/vm_tong/$vm_name/" /tmp/${vm_name}.xml &>/dev/null

                virsh define /tmp/${vm_name}.xml &>/dev/null
                echo "虚拟机${vm_name}重置完成......"
		#virsh start ${vm_name}
        done	
}


rhel6
