#!/bin/bash
user_list=/ldap_user.txt
group_list=/ldap_group.txt
user_ldif=/ldap_user.ldif
group_ldif=/ldap_group.ldif
mig_user=/usr/share/migrationtools/migrate_passwd.pl
mig_group=/usr/share/migrationtools/migrate_group.pl
rootdn="cn=Manager,dc=example,dc=org"
rootpw=redhat
rootDN="dc=example,dc=org"
hostip=localhost

for user in $(cat newuser.txt)
#while :
do
 
	
dn=`ldapsearch -x -h $hostip -b "$rootDN" |grep $user |grep cn=$user | awk '{print $2}'` 
 ldapdelete  -x -D "$rootdn" -w $rootpw -h $hostip "$dn" &>/dev/null && u1=1 || u1=0



	if [ "$u1" = 1  ] ;then
		echo "删除用户$user成功!"
	fi
done
