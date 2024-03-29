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
dnf install -y zabbix-agent-5.4.4-1.el8
sed -i "s/Server=127.0.0.1/Server=127.0.0.1,$6/g" /etc/zabbix/zabbix_agentd.conf
systemctl restart zabbix-agent zabbix-get
echo "zabbix-get usage reminder:"
echo 'zabbix_get -s 127.0.0.1 -p 10050 -k "system.cpu.load[all,avg1]"'
systemctl enable zabbix-agent

if [[ $HOSTNAME = "zabbixserver1" ]]
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
    systemctl status postgresql-13

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
    echo "************************** INSTALLING ZABBIX-SERVER ***************************"
    echo "*******************************************************************************"
    rpm -Uvh https://repo.zabbix.com/zabbix/5.4/rhel/8/x86_64/zabbix-release-5.4-1.el8.noarch.rpm
    dnf install -y zabbix-server-pgsql-5.4.4-1.el8 zabbix-web-pgsql-5.4.4-1.el8 zabbix-nginx-conf-5.4.4-1.el8 zabbix-sql-scripts-5.4.4-1.el8
    su - postgres -c 'psql --command "CREATE USER zabbix WITH PASSWORD '\'123456789\'';"'
    su - postgres -c 'psql --command "CREATE DATABASE zabbix OWNER zabbix;"'
    zcat /usr/share/doc/zabbix-sql-scripts/postgresql/create.sql.gz | sudo -u zabbix psql zabbix
    sed -i "s/# DBPassword=/DBPassword=123456789/g" /etc/zabbix/zabbix_server.conf
    sed -i 's/#        listen          80;/        listen          80;/g' /etc/nginx/conf.d/zabbix.conf
    sed -i 's/#        server_name     example.com;/        server_name     zabbix.lan;/g' /etc/nginx/conf.d/zabbix.conf
    systemctl restart zabbix-server nginx php-fpm
    systemctl enable zabbix-server nginx php-fpm
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