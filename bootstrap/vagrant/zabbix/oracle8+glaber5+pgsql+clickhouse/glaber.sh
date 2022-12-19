# repo override
#kz
#sed -i 's/us.archive.ubuntu.com/mirror.hoster.kz/g' /etc/apt/sources.list
#ru
#sed -i 's/us.archive.ubuntu.com/mirror.linux-ia64.org/g' /etc/apt/sources.list

useradd $1 -s /bin/bash -d /home/test
mkdir /home/test
chown -R test:test /home/test
echo ''$1'    ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

usermod --password $(openssl passwd -6 $2) root
usermod --password $(openssl passwd -6 $2) $1

if [ $3 == "true" ]; then yum update -y; else echo '$3'=$3; fi

rm -Rf /etc/hosts

echo "127.0.0.1	localhost.localdomain	localhost" >> /etc/hosts
echo "$5	$4.localdomain	$4" >> /etc/hosts

echo "*******************************************************************************"
echo "************************** INSTALLING ZABBIX-AGENT ***************************"
echo "*******************************************************************************"
rpm -Uvh https://repo.zabbix.com/zabbix/5.4/rhel/8/x86_64/zabbix-release-5.4-1.el8.noarch.rpm
dnf install -y zabbix-agent-5.4.4-1.el8 zabbix-get-5.4.4-1.el8
sed -i "s/Server=127.0.0.1/Server=127.0.0.1,$6/g" /etc/zabbix/zabbix_agentd.conf
systemctl restart zabbix-agent zabbix-get
echo "zabbix-get usage reminder:"
echo 'zabbix_get -s 127.0.0.1 -p 10050 -k "system.cpu.load[all,avg1]"'
systemctl enable zabbix-agent


if [[ $HOSTNAME = "glaberserver1" ]]
then
    echo "*******************************************************************************"
    echo "************************** INSTALLING POSTGRESQL ***************************"
    echo "*******************************************************************************"
    #dnf install -y libpq5
    dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
    dnf -qy module disable postgresql
    dnf install -y postgresql13-server
    /usr/pgsql-13/bin/postgresql-13-setup initdb
    systemctl enable postgresql-13
    systemctl start postgresql-13
    systemctl status postgresql-13qw


    rpm -e --nodeps libpq5-15.1-42PGDG.rhel8.x86_64
    rpm -i https://rpmfind.net/linux/centos/8-stream/AppStream/x86_64/os/Packages/libpq-13.3-1.el8_4.x86_64.rpm
    rm /usr/pgsql-14/lib/libpq.so.5

    # sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
    # sudo dnf -qy module disable postgresql
    # sudo dnf install -y postgresql14-server
    # sudo /usr/pgsql-14/bin/postgresql-14-setup initdb
    # sudo systemctl enable postgresql-14
    # sudo systemctl start postgresql-14
    # systemctl status postgresql-14

    echo "*******************************************************************************"
    echo "************************** INSTALLING GLABER-SERVER ***************************"
    echo "*******************************************************************************"

    cat > /etc/yum.repos.d/glaber.repo << EOL
[glaber]
name=Glaber Official Repository
baseurl=https://glaber.io/repo/rhel/8
enabled=1
gpgcheck=0
EOL
    dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
    dnf -y install glaber-server-pgsql glaber-nginx-conf glaber-web-pgsql php74-php-pgsql.x86_64 zabbix-sql-scripts zabbix-agent
    # echo "*******************************************************************************"
    # echo "************************** INSTALLING ZABBIX-SERVER ***************************"
    # echo "*******************************************************************************"
    # rpm -Uvh https://repo.zabbix.com/zabbix/5.4/rhel/8/x86_64/zabbix-release-5.4-1.el8.noarch.rpm
    # dnf install -y zabbix-server-pgsql-5.4.4-1.el8 zabbix-web-pgsql-5.4.4-1.el8 zabbix-nginx-conf-5.4.4-1.el8 zabbix-sql-scripts-5.4.4-1.el8
    su - postgres -c 'psql --command "CREATE USER zabbix WITH PASSWORD '\'123456789\'';"'
    su - postgres -c 'psql --command "CREATE DATABASE zabbix OWNER zabbix;"'
    zcat /usr/share/doc/glaber-server-pgsql/create.sql.gz | sudo -u zabbix psql zabbix
    sed -i "s/# DBPassword=/DBPassword=123456789/g" /etc/zabbix/zabbix_server.conf
    sed -i 's/#        listen          80;/        listen          80;/g' /etc/nginx/conf.d/zabbix.conf
    sed -i 's/#        server_name     example.com;/        server_name     glaber5.lan;/g' /etc/nginx/conf.d/zabbix.conf
    
    sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php.ini
    sed -i 's/post_max_size = 8M/post_max_size = 64M/g' /etc/php.ini
    sed -i 's/max_execution_time = 30/max_execution_time = 60/g' /etc/php.ini
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 32M/g' /etc/php.ini
    sed -i 's/max_input_time = 60/max_input_time = 60/g' /etc/php.ini
    #sed -i 's/;date.timezone =/date.timezone = Europe/Moscow/g' /etc/php.ini
    # sed -i 's///g' /etc/php.ini
    # sed -i 's///g' /etc/php.ini
    # sed -i 's///g' /etc/php.ini
    # systemctl restart zabbix-server nginx php-fpm
    # systemctl enable zabbix-server nginx php-fpm


    echo "*******************************************************************************"
    echo "*************************** INSTALLING CLICKHOUSE *****************************"
    echo "*******************************************************************************"

    yum install -y yum-utils
    yum-config-manager --add-repo https://packages.clickhouse.com/rpm/clickhouse.repo
    yum install -y clickhouse-server clickhouse-client
    /etc/init.d/clickhouse-server start
cat > /etc/clickhouse-server/config.d/query_log.xml << EOL
<yandex>
    <query_log replace="1">
    <database>system</database>

    <table>query_log</table>
        <flush_interval_milliseconds>7500</flush_interval_milliseconds>
        <engine>
          ENGINE = MergeTree
          PARTITION BY event_date
          ORDER BY (event_time)
          TTL event_date + interval 90 day
          SETTINGS ttl_only_drop_parts=1
        </engine>
    </query_log>
</yandex>
EOL

cat > /etc/clickhouse-server/config.d/disable_query_thread_log.xml << EOL
<yandex>
    <query_thread_log remove="1"/>
</yandex>
EOL

cat > /etc/clickhouse-server/config.d/part_log.xml << EOL
<yandex>
    <part_log remove="1" />
</yandex>
EOL

# cat > /etc/clickhouse-server/users.d/log_queries.xml << EOL
# <yandex>
#   <profiles>
#     <default>
#       <log_queries>1</log_queries>
#     </default>
#   </profiles>
# </yandex>
# EOL

cat > /etc/clickhouse-server/users.d/enable_on_disk_operations.xml << EOL
<yandex>
  <profiles>
    <default>
      <max_bytes_before_external_group_by>2000000000</max_bytes_before_external_group_by>
      <max_bytes_before_external_sort>2000000000</max_bytes_before_external_sort>
     </default>
  </profiles>
</yandex>
EOL

cat > /root/history.sql << EOL
CREATE DATABASE glaber;
CREATE TABLE glaber.history_dbl (   day Date,  
                                itemid UInt64,  
                                clock DateTime,  
                                hostname String,
                                itemname String,
                                ns UInt32, 
                                value Float64
                            ) ENGINE = MergeTree()
PARTITION BY toYYYYMM(day)
ORDER BY (itemid, clock) 
TTL day + INTERVAL 6 MONTH;

--                            
CREATE TABLE glaber.history_uint (   day Date,  
                                itemid UInt64,  
                                clock DateTime,  
                                hostname String,
                                itemname String,
                                ns UInt32, 
                                value UInt64  
                            ) ENGINE = MergeTree()
PARTITION BY toYYYYMM(day)
ORDER BY (itemid, clock) 
TTL day + INTERVAL 6 MONTH;

CREATE TABLE glaber.history_str (   day Date,  
                                itemid UInt64,  
                                clock DateTime,  
                                hostname String,
                                itemname String,
                                ns UInt32, 
                                value String  
                            ) ENGINE = MergeTree()
PARTITION BY toYYYYMM(day)
ORDER BY (itemid, clock) 
TTL day + INTERVAL 6 MONTH;

--
CREATE TABLE glaber.history_log (   day Date,  
                                itemid UInt64,  
                                clock DateTime,  
                                logeventid UInt64,
                                source  String,
                                severity Int16,
                                hostname String,
                                itemname String,
                                ns UInt32, 
                                value String
                            ) ENGINE = MergeTree()
PARTITION BY toYYYYMM(day)
ORDER BY (itemid, clock) 
TTL day + INTERVAL 6 MONTH;

--
CREATE TABLE glaber.trends_dbl
(
    day Date,
    itemid UInt64,
    clock DateTime,
    value_min Float64,
    value_max Float64,
    value_avg Float64,
    count UInt32,
    hostname String,
    itemname String
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(day)
ORDER BY (itemid, clock)
TTL day + toIntervalMonth(24)
SETTINGS index_granularity = 8192;

--
CREATE TABLE glaber.trends_uint
(
    day Date,
    itemid UInt64,
    clock DateTime,
    value_min Int64,  
    value_max Int64,
    value_avg Int64,
    count UInt32,
    hostname String,
    itemname String
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(day)
ORDER BY (itemid, clock)
TTL day + toIntervalMonth(24)
SETTINGS index_granularity = 8192;

-- some stats guide
-- https://gist.github.com/sanchezzzhak/511fd140e8809857f8f1d84ddb937015
-- to submit all CREATE TABLE queries at once, run "clickhouse-client" with the "--multiquery" param
EOL

    clickhouse-client --multiquery < /root/history.sql

    sed -i 's/# CacheSize=8M/CacheSize=256M/g' /etc/zabbix/zabbix_server.conf
    sed -i 's/# StartDBSyncers=4/StartDBSyncers=1/g' /etc/zabbix/zabbix_server.conf
    sed -i 's/# StartPollers=5/StartPollers=10/g' /etc/zabbix/zabbix_server.conf
    sed -i 's/# StartPollersUnreachable=1/StartPollersUnreachable=1/g' /etc/zabbix/zabbix_server.conf
    sed -i 's/# HousekeepingFrequency=1/HousekeepingFrequency=1/g' /etc/zabbix/zabbix_server.conf
    sed -i 's/# StartTrappers=5/StartTrappers=4/g' /etc/zabbix/zabbix_server.conf
    sed -i 's/# StartPingers=1/StartPingers=2/g' /etc/zabbix/zabbix_server.conf
    # sed -i 's///g' /etc/zabbix/zabbix_server.conf
    # sed -i 's///g' /etc/zabbix/zabbix_server.conf
    # sed -i 's///g' /etc/zabbix/zabbix_server.conf
    # sed -i 's///g' /etc/zabbix/zabbix_server.conf

    echo 'StartGlbWorkers=1' >> /etc/zabbix/zabbix_server.conf
    echo 'StartGlbSNMPPollers=1' >> /etc/zabbix/zabbix_server.conf
    echo 'DefaultICMPMethod=glbmap' >> /etc/zabbix/zabbix_server.conf
    echo 'DefaultICMPMethod=fping' >> /etc/zabbix/zabbix_server.conf
    echo 'StartGlbPingers=1' >> /etc/zabbix/zabbix_server.conf
    echo 'GlbmapOptions=-i ens160 -G 00:50:56:9e:7c:9e' >> /etc/zabbix/zabbix_server.conf
    echo 'GlbmapLocation=/usr/sbin/glbmap' >> /etc/zabbix/zabbix_server.conf
    chmod +s /usr/sbin/glbmap
    echo 'StartGlbAgentPollers=1' >> /etc/zabbix/zabbix_server.conf
    echo 'StartAPITrappers=2' >> /etc/zabbix/zabbix_server.conf
    echo 'StartPreprocessorManagers=1' >> /etc/zabbix/zabbix_server.conf
    echo 'StartPreprocessorsPerManager=4' >> /etc/zabbix/zabbix_server.conf
    echo 'HistoryModule=clickhouse;{"url":"http://127.0.0.1:8123", "username":"default", "dbname":"glaber", "disable_reads":100, "timeout":10 }' >> /etc/zabbix/zabbix_server.conf
    echo 'WorkerScripts=/usr/lib/zabbix/workerscripts' >> /etc/zabbix/zabbix_server.conf
    echo 'ValueCacheDumpLocation=/tmp/vcdump' >> /etc/zabbix/zabbix_server.conf
    echo 'ValueCacheDumpFrequency = 300' >> /etc/zabbix/zabbix_server.conf
    mkdir /tmp/vcdump/
    chmod 777 /tmp/vcdump/
    chown -R zabbix:zabbix /tmp/vcdump/ 
    # echo '' >> /etc/zabbix/zabbix_server.conf
    # echo '' >> /etc/zabbix/zabbix_server.conf
    # echo '' >> /etc/zabbix/zabbix_server.conf
    # echo '' >> /etc/zabbix/zabbix_server.conf
    

    echo 'global $HISTORY;' >> /etc/zabbix/web/maintenance.inc.php
    echo '$HISTORY['storagetype']='server';' >> /etc/zabbix/web/maintenance.inc.php

    /etc/init.d/clickhouse-server stop
    /etc/init.d/clickhouse-server start
    /etc/init.d/clickhouse-server stop
    systemctl start clickhouse-server
    systemctl status clickhouse-server
    systemctl restart postgresql-13
    systemctl status postgresql-13
    systemctl restart nginx
    systemctl status nginx
    systemctl restart php-fpm
    systemctl status php-fpm
    systemctl restart zabbix-server
    systemctl status zabbix-server
    systemctl restart zabbix-agent
    systemctl status zabbix-agent


    systemctl status clickhouse-server
    systemctl status postgresql-13
    systemctl status nginx
    systemctl status php-fpm
    systemctl status zabbix-server
    systemctl status zabbix-agent
fi
#sed -i 's/; php_value[date.timezone] = Europe/Riga/listen 80;/g' /etc/nginx/conf.d/zabbix.conf

# sed -i "s/Server=127.0.0.1/Server=$6/g" /etc/zabbix/zabbix_agentd.conf

#su - postgres -c 'psql --command "GRANT ALL PRIVILEGES ON DATABASE zabbix TO zabbix;"'

# echo 'UserParameter=custom_echo[*],echo $1' >> /etc/zabbix/zabbix_agentd.conf
# echo 'UserParameter=my_script[*], python3 /etc/zabbix/test_python_script.py $1 $2' > /etc/zabbix/zabbix_agentd.d/test_user_parameter.conf
# systemctl restart zabbix-agent
# systemctl enable zabbix-agent

# if [[ ! -f /etc/zabbix/test_python_script.py ]]
# then
#     echo 'import sys' >> /etc/zabbix/test_python_script.py
#     echo 'import os' >> /etc/zabbix/test_python_script.py
#     echo 'import re' >> /etc/zabbix/test_python_script.py
#     echo 'if (sys.argv[1] == "-ping"): # Если -ping' >> /etc/zabbix/test_python_script.py
#     echo '        result=os.popen("ping -c 1 " + sys.argv[2]).read() # Делаем пинг по заданному адресу' >> /etc/zabbix/test_python_script.py
#     echo '        result=re.findall(r"time=(.*) ms", result) # Выдёргиваем из результата время' >> /etc/zabbix/test_python_script.py
#     echo '        print(result[0]) # Выводим результат в консоль' >> /etc/zabbix/test_python_script.py
#     echo 'elif (sys.argv[1] == "-simple_print"): # Если simple_print ' >> /etc/zabbix/test_python_script.py
#     echo '        print(sys.argv[2]) # Выводим в консоль содержимое sys.arvg[2]' >> /etc/zabbix/test_python_script.py
#     echo 'else: # Во всех остальных случаях' >> /etc/zabbix/test_python_script.py
#     echo '        print(f"unknown input: {sys.argv[1]}") # Выводим непонятый запрос в консоль.' >> /etc/zabbix/test_python_script.py
# fi


# echo "*******************************************************************************"
# echo "********************************* END *****************************************"
# echo "*******************************************************************************"