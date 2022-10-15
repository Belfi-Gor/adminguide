# repo override
sed -i 's/us.archive.ubuntu.com/mirror.hoster.kz/g' /etc/apt/sources.list

useradd $1 -s /bin/bash -d /home/test
mkdir /home/test
chown -R test:test /home/test

usermod --password $(openssl passwd -6 $2) root
usermod --password $(openssl passwd -6 $2) $1


apt update
apt install htop
if [ $3 == "true" ]; then apt upgrade -y; else echo '$3'=$3; fi

rm -Rf /etc/hosts

echo "127.0.0.1	localhost.localdomain	localhost" >> /etc/hosts
echo "$5	$4.localdomain	$4" >> /etc/hosts

apt install default-jre -y

echo "*******************************************************************************"
echo "************************** INSTALLING JENKINS *********************************"
echo "*******************************************************************************"
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
echo 'deb http://pkg.jenkins.io/debian-stable binary/' > /etc/apt/sources.list.d/jenkins.list
apt update
apt install jenkins -y
systemctl enable jenkins
systemctl start jenkins

echo "*******************************************************************************"
echo "*************************** INSTALLING ANSIBLE ********************************"
echo "*******************************************************************************"
apt install ansible -y


#echo "*******************************************************************************"
#echo "*************************** INSTALLING PUPPET *********************************"
#echo "*******************************************************************************"
#wget https://apt.puppetlabs.com/puppet7-release-focal.deb 
#dpkg -i puppet7-release-focal.deb 
#apt update 
#apt install puppetserver -y
#sed -i 's/2g /1g /g' /etc/puppetlabs/puppet/puppet.conf 

#puppetserver ca setup

#systemctl start puppetserver 
#systemctl enable puppetserver 

#wget https://apt.puppetlabs.com/puppet6-release-focal.deb
#dpkg -i puppet6-release-focal.deb
#apt update -y
#apt install puppet -y
#apt install puppetserver -y



#apt install postgresql -y

#su - postgres -c 'psql --command "CREATE USER zabbix WITH PASSWORD '\'$3\'';"'

#sudo -u postgres createdb -O zabbix zabbix

#

#wget $5

#dpkg -i zabbix-release*.deb

#apt update

#apt install zabbix-server-pgsql zabbix-frontend-php php7.3-pgsql zabbix-apache-conf zabbix-sql-scripts zabbix-agent nano -y

#zcat /usr/share/doc/zabbix-sql-scripts/postgresql/create.sql.gz | sudo -u zabbix psql zabbix

#sed -i 's/# DBPassword=/DBPassword='$3'/g' /etc/zabbix/zabbix_server.conf

#sudo systemctl restart zabbix-server zabbix-agent apache2
#sudo systemctl enable zabbix-server zabbix-agent apache2

echo "*******************************************************************************"
echo "********************************* END *****************************************"
echo "*******************************************************************************"