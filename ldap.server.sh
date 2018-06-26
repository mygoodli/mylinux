#!/bin/bash
iptables -F
setenforce 0

yum -y install openldap-clients openldap-servers openldap migrationtools 
######slappasswd
SLAPPASSWD={SSHA}ngdJPr/eYMuok7fkGuRbyVVSyjtia4Pa
DC0=uplooking
DC1=com


cat > /etc/openldap/slapd.conf <<EOF
include         /etc/openldap/schema/corba.schema
include         /etc/openldap/schema/core.schema
include         /etc/openldap/schema/cosine.schema
include         /etc/openldap/schema/duaconf.schema
include         /etc/openldap/schema/dyngroup.schema
include         /etc/openldap/schema/inetorgperson.schema
include         /etc/openldap/schema/java.schema
include         /etc/openldap/schema/misc.schema
include         /etc/openldap/schema/nis.schema
include         /etc/openldap/schema/openldap.schema
include         /etc/openldap/schema/pmi.schema
include         /etc/openldap/schema/ppolicy.schema
include         /etc/openldap/schema/collective.schema
allow bind_v2
pidfile         /var/run/openldap/slapd.pid
argsfile        /var/run/openldap/slapd.args
####  Encrypting Connections
TLSCACertificateFile /etc/pki/tls/certs/ca.crt
TLSCertificateFile /etc/pki/tls/certs/slapd.crt
TLSCertificateKeyFile /etc/pki/tls/certs/slapd.key
### Database Config###          
database config
rootdn "cn=admin,cn=config"
rootpw $SLAPPASSWD
access to * by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage by * break
### Enable Monitoring
database monitor
# allow only rootdn to read the monitor
access to * by dn.exact="cn=admin,cn=config" read by * none
EOF

rm -rf /etc/openldap/slapd.d/*

slaptest -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d/

chown -R ldap:ldap /etc/openldap/slapd.d

chmod -R 000 /etc/openldap/slapd.d

chmod -R u+rwX /etc/openldap/slapd.d

#########mkcert.sh##要将mkcert.sh放在/root下
/root/mkcert.sh --create-ca-keys

/root/mkcert.sh --create-ldap-keys

cp /etc/pki/CA/my-ca.crt /etc/pki/tls/certs/ca.crt
cp /etc/pki/CA/ldap_server.crt /etc/pki/tls/certs/slapd.crt
cp /etc/pki/CA/ldap_server.key /etc/pki/tls/certs/slapd.key

rm -fr /var/lib/ldap/*
chown ldap.ldap /var/lib/ldap/

cp -p /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown ldap. /var/lib/ldap/DB_CONFIG

systemctl start  slapd.service
if [ $? -eq 0 ]
then echo -e "\033[32m slapd.service Success \033[0m"
else exit 17
fi

###############DB################
pw=redhat
mkdir /root/ldif
cat  >/root/ldif/bdb.ldif <<EOF
dn: olcDatabase=bdb,cn=config
objectClass: olcDatabaseConfig
objectClass: olcBdbConfig
olcDatabase: {1}bdb
olcSuffix: dc=$DC0,dc=$DC1
olcDbDirectory: /var/lib/ldap
olcRootDN: cn=Manager,dc=$DC0,dc=$DC1
olcRootPW: $pw
olcLimits: dn.exact="cn=Manager,dc=$DC0,dc=$DC1" time.soft=unlimited time.hard=unlimited size.soft=unlimited size.hard=unlimited
olcDbIndex: uid pres,eq
olcDbIndex: cn,sn,displayName pres,eq,approx,sub
olcDbIndex: uidNumber,gidNumber eq
olcDbIndex: memberUid eq
olcDbIndex: objectClass eq
olcDbIndex: entryUUID pres,eq
olcDbIndex: entryCSN pres,eq
olcAccess: to attrs=userPassword by self write by anonymous auth by dn.children="ou=admins,dc=$DC0,dc=$DC1" write  by * none
olcAccess: to * by self write by dn.children="ou=admins,dc=$DC0,dc=$DC1" write by * read
EOF



ldapadd -x -D "cn=admin,cn=config" -w config -f ~/ldif/bdb.ldif -h localhost
ldapsearch -x -b "cn=config" -D "cn=admin,cn=config" -w config -h localhost dn -LLL | grep -v ^$ |tail -1
dc=example.org
dcdc="dc=example,dc=org"
sed -i 's/DEFAULT_MAIL_DOMAIN = "'$dc'"/DEFAULT_MAIL_DOMAIN = "'$DC0'"/' /usr/share/migrationtools/migrate_common.ph

sed -i 's/DEFAULT_BASE = "'$dcdc'"/DEFAULT_BASE = "dc='$DC0',dc='$DC1'"/' /usr/share/migrationtools/migrate_common.ph


#######ca
yum -y install httpd
cp /etc/pki/tls/certs/ca.crt /var/www/html/
systemctl start httpd

#######home
mkdir -p /ldapuser
yum -y install nfs-utils.x86_64 rpcbind 

cat >/etc/exports <<EOT
/ldapuser 192.168.78.0/24(rw,sync)
EOT

service rpcbind restart
service nfs start

showmount -e localhost

