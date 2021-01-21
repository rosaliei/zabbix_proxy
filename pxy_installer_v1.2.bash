 #ENV Setup
 systemctl stop firewalld
 systemctl disable firewalld
 setenforce 0 
 yum install wget git vim -y
 
 #Part1
 #Zabbix Proxy Instllation
 rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/8/x86_64/zabbix-release-5.0-1.el8.noarch.rpm
 dnf clean all
 yum install zabbix-proxy-pgsql git -y
 
 #Zabbix Proxy DB Configuration
 sudo -i -u postgres createuser zabbix
 sudo -i -u postgres psql -c "ALTER USER zabbix WITH PASSWORD 'zabbixproxy123';"
 sudo -i -u postgres createdb -O zabbix zabbix_proxy
 zcat /usr/share/doc/zabbix-proxy-pgsql/schema.sql.gz | sudo -i -u postgres psql zabbix_proxy

 
 #Part2
 #Zabbix Proxy Configuration
 
 cp -rv /etc/zabbix/zabbix_proxy.conf /etc/zabbix/zabbix_proxy.conf.bak
 
 sed -i '49s/Hostname/#Hostname/' /etc/zabbix/zabbix_proxy.conf
 sed -i '30s/Server/#Server/' /etc/zabbix/zabbix_proxy.conf
 sed -i '102s/LogFile/#LogFile/' /etc/zabbix/zabbix_proxy.conf
 sed -i '173s/DBName/#DBName/' /etc/zabbix/zabbix_proxy.conf
 sed -i '188s/DBUser/#DBUser/' /etc/zabbix/zabbix_proxy.conf

 echo >> /etc/zabbix/zabbix_proxy.conf
 echo >> /etc/zabbix/zabbix_proxy.conf
 echo #Active Proxy Config >> /etc/zabbix/zabbix_proxy.conf
 echo >> /etc/zabbix/zabbix_proxy.conf
 echo >> /etc/zabbix/zabbix_proxy.conf
 echo "Hostname=$(hostname)" >> /etc/zabbix/zabbix_proxy.conf
 echo "ProxyMode=0" >> /etc/zabbix/zabbix_proxy.conf 
 echo "Server=10.63.18.151" >> /etc/zabbix/zabbix_proxy.conf 
 echo "LogFileSize=100" >> /etc/zabbix/zabbix_proxy.conf
 echo "EnableRemoteCommands=1" >> /etc/zabbix/zabbix_proxy.conf 
 echo "DBHost=localhost" >> /etc/zabbix/zabbix_proxy.conf
 echo "DBName=zabbix_proxy" >> /etc/zabbix/zabbix_proxy.conf 
 echo "DBUser=postgres" >> /etc/zabbix/zabbix_proxy.conf 
 echo "DBPassword=zabbixproxy1234" >> /etc/zabbix/zabbix_proxy.conf 
 echo "ProxyLocalBuffer=24" >> /etc/zabbix/zabbix_proxy.conf
 echo "ProxyOfflineBuffer=168">> /etc/zabbix/zabbix_proxy.conf
 echo "HeartbeatFrequency=60" >> /etc/zabbix/zabbix_proxy.conf
 echo "ConfigFrequency=60" >> /etc/zabbix/zabbix_proxy.conf
 echo "DataSenderFrequency=5" >> /etc/zabbix/zabbix_proxy.conf
 echo "StartPollers=320" >> /etc/zabbix/zabbix_proxy.conf
 echo "StartPollersUnreachable=60" >> /etc/zabbix/zabbix_proxy.conf
 echo "StartTrappers=10" >> /etc/zabbix/zabbix_proxy.conf
 echo "StartPingers=60" >> /etc/zabbix/zabbix_proxy.conf
 echo "StartDiscoverers=20" >> /etc/zabbix/zabbix_proxy.conf
 echo "StartHTTPPollers=36" >> /etc/zabbix/zabbix_proxy.conf
 echo "StartVMwareCollectors=150" >> /etc/zabbix/zabbix_proxy.conf
 echo "VMwareFrequency=60" >> /etc/zabbix/zabbix_proxy.conf
 echo "VMwarePerfFrequency=60" >> /etc/zabbix/zabbix_proxy.conf
 echo "VMwareCacheSize=1G" >> /etc/zabbix/zabbix_proxy.conf
 echo "VMwareTimeout=30" >> /etc/zabbix/zabbix_proxy.conf
 echo "CacheSize=2G" >> /etc/zabbix/zabbix_proxy.conf
 echo "StartDBSyncers=12" >> /etc/zabbix/zabbix_proxy.conf
 echo "HistoryCacheSize=512M" >> /etc/zabbix/zabbix_proxy.conf
 echo "HistoryIndexCacheSize=12M" >> /etc/zabbix/zabbix_proxy.conf
 
 systemctl start zabbix-proxy
 systemctl enable zabbix-proxy
 
 #Part3
 # SNMP TRAP INSTALLATION
 
 yum install net-snmp net-snmp-utils net-snmp-perl -y
 
 # MIB INSTALLATION
 
 cd /tmp && git clone https://gitlab.gtmh-telecom.com/hsumyatthwe/mib-collection.git
 \cp -rvf /tmp/mib-collection/mibs/ /usr/share/snmp/mibs/
 
 #SNMP TRAP Configuration
 
 cd /tmp &&  wget https://cdn.zabbix.com/zabbix/sources/stable/5.0/zabbix-5.0.7.tar.gz
 tar -zxvf /tmp/zabbix-5.0.7.tar.gz
 cp /tmp/zabbix-5.0.7/misc/snmptrap/zabbix_trap_receiver.pl /usr/bin/
 chmod +x /usr/bin/zabbix_trap_receiver.pl
 echo >> /etc/snmp/snmptrapd.conf
 echo "disableAuthorization yes" >> /etc/snmp/snmptrapd.conf
 echo 'perl do "/usr/bin/zabbix_trap_receiver.pl";' >> /etc/snmp/snmptrapd.conf
 echo
 echo "###Option: StartSNMPTrapper" >> /etc/zabbix/zabbix_proxy.conf
 echo "StartSNMPTrapper=1" >> /etc/zabbix/zabbix_proxy.conf
 
 systemctl restart snmptrapd
 systemctl enable snmptrapd
 systemctl restart snmpd
 systemctl enable snmpd
 
 #Confirming SNMPTRAP working with Zabbix Perl Trap Receiver
 snmptrapd -On 
 
 echo "ZABBIX LOG LOCATION : $(cat /usr/bin/zabbix_trap_receiver.pl | grep '^$SNMPTrapperFile' | awk '{print $3}')"
 systemctl restart zabbix-proxy
 
 #Changing SNMP Trap output to produce only OID
 sed -i '9s/snmptrapd/snmptrapd -On/' /usr/lib/systemd/system/snmptrapd.service 
 
 systemctl daemon-reload
 systemctl restart snmpd
 systemctl restart snmptrapd
 systemctl restart zabbix-proxy