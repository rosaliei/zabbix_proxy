 # Env Setup
 yum install wget git vim -y 

 # Backup Zabbix Server Configuration
 
 cp -rv /etc/zabbix/zabbix_server.conf /etc/zabbix/zabbix_server.conf.bak

 # SNMP TRAP INSTALLATION
 yum install net-snmp net-snmp-utils net-snmp-perl -y

 # MIB INSTALLATION
 
 cd /usr/local/src && git clone https://gitlab.gtmh-telecom.com/hsumyatthwe/mib-collection.git
 \cp -rvf /usr/local/src/mib-collection/mibs/ /usr/share/snmp/mibs/
 
 #SNMP TRAP Configuration
 
 cd /usr/local/src &&  wget https://cdn.zabbix.com/zabbix/sources/stable/5.0/zabbix-5.0.7.tar.gz
 tar -zxvf /usr/local/src/zabbix-5.0.7.tar.gz
 cp /usr/local/src/zabbix-5.0.7/misc/snmptrap/zabbix_trap_receiver.pl /usr/bin/
 chmod +x /usr/bin/zabbix_trap_receiver.pl
 echo >> /etc/snmp/snmptrapd.conf
 echo "disableAuthorization yes" >> /etc/snmp/snmptrapd.conf
 echo 'perl do "/usr/bin/zabbix_trap_receiver.pl";' >> /etc/snmp/snmptrapd.conf
 echo
 echo "###Option: StartSNMPTrapper" >> /etc/zabbix/zabbix_server.conf
 echo "StartSNMPTrapper=1" >> /etc/zabbix/zabbix_server.conf
 
 systemctl restart snmptrapd
 systemctl enable snmptrapd
 systemctl restart snmpd
 systemctl enable snmpd
 
 #Confirming SNMPTRAP working with Zabbix Perl Trap Receiver
 snmptrapd -On 
 
 echo "ZABBIX LOG LOCATION : $(cat /usr/bin/zabbix_trap_receiver.pl | grep '^$SNMPTrapperFile' | awk '{print $3}')"
 systemctl restart zabbix-server
 
 #Changing SNMP Trap output to produce only OID
 sed -i '9s/snmptrapd/snmptrapd -On/' /usr/lib/systemd/system/snmptrapd.service 
 
 systemctl daemon-reload
 systemctl restart snmpd
 systemctl restart snmptrapd
 systemctl restart zabbix-server

