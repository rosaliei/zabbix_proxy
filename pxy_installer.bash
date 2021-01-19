 #!/bin/bash
 
 systemctl stop firewalld
 setenforce 0 
 
 rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/8/x86_64/zabbix-release-5.0-1.el8.noarch.rpm
 dnf clean all
 yum install zabbix-proxy-pgsql git -y
 
 sudo -i -u postgres createuser zabbix
 sudo -i -u postgres psql -c "ALTER USER zabbix WITH PASSWORD 'zabbixproxy123';"
 sudo -i -u postgres createdb -O zabbix zabbix_proxy
 zcat /usr/share/doc/zabbix-proxy-pgsql/schema.sql.gz | sudo -u zabbix_proxy psql zabbixproxy123

 cat /etc/zabbix/zabbix_proxy.conf | head -n 35 | tail -n 10 | sed 's/Server/#Server/g'	

 echo >> /etc/zabbix/zabbix_proxy.conf
 echo >> /etc/zabbix/zabbix_proxy.conf
 echo #Active Proxy Config >> /etc/zabbix/zabbix_proxy.conf
 echo >> /etc/zabbix/zabbix_proxy.conf
 echo >> /etc/zabbix/zabbix_proxy.conf
 echo "ProxyMode=0" >> /etc/zabbix/zabbix_proxy.conf
 echo "Server=10.63.18.151" >> /etc/zabbix/zabbix_proxy.conf
 echo "LogFile=/var/log/zabbix/zabbix_proxy.log" >> /etc/zabbix/zabbix_proxy.conf
 echo "LogFileSize=100" >> /etc/zabbix/zabbix_proxy.conf
 echo "EnableRemoteCommands=1" >> /etc/zabbix/zabbix_proxy.conf
 echo "PidFile=/var/run/zabbix/zabbix_proxy.pid" >> /etc/zabbix/zabbix_proxy.conf
 echo "SocketDir=/var/run/zabbix" >> /etc/zabbix/zabbix_proxy.conf
 echo "DBHost=localhost" >> /etc/zabbix/zabbix_proxy.conf
 echo "DBName=zabbix_proxy" >> /etc/zabbix/zabbix_proxy.conf
 echo "DBUser=zabbix" >> /etc/zabbix/zabbix_proxy.conf
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
 echo "Timeout=5" >> /etc/zabbix/zabbix_proxy.conf
 echo "ExternalScripts=/usr/lib/zabbix/externalscripts" >> /etc/zabbix/zabbix_proxy.conf
 echo "LogSlowQueries=3000" >> /etc/zabbix/zabbix_proxy.conf
 
 systemctl enable zabbix-proxy
 systemctl start zabbix-proxy
 
 
 echo "Proxy Installation Done !!!"


 
 