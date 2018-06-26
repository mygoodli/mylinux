#!/bin/bash
user_list=/ldap_user.txt
group_list=/ldap_group.txt
user_ldif=/ldap_user.ldif
group_ldif=/ldap_group.ldif
mig_user=/usr/share/migrationtools/migrate_passwd.pl
mig_group=/usr/share/migrationtools/migrate_group.pl
rootdn="cn=Manager,dc=example,dc=org"
rootpw=redhat


for user in $(cat newuser.txt)
#while :
do
 
	#read -p "请输入要创建的LDAP User[输入q推测出]:" user
	#if [ "$user" = "q" ] ;then
	#   exit
	#fi
	
	useradd $user -d /ldapuser/$user &>/dev/null
	echo "123456" | passwd --stdin $user &> /dev/null 
	egrep "\<$user\>" /etc/passwd > $user_list
	egrep "\<$user\>" /etc/group >  $group_list
	$mig_user $user_list > $user_ldif
	$mig_group $group_list > $group_ldif
	ldapadd -x -D $rootdn -w $rootpw -c -f $user_ldif &> /dev/null && u1=1 || u1=0
	ldapadd -x -D $rootdn -w $rootpw -c -f $group_ldif &> /dev/null && u2=1 || u2=0
	if [ "$u1" = 1 -a "$u2" = 1 ] ;then
		echo "添加用户$user成功!"
	fi
done
