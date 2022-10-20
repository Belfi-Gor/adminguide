# repo override
#kz
#sed -i 's/us.archive.ubuntu.com/mirror.hoster.kz/g' /etc/apt/sources.list
#ru
sed -i 's/us.archive.ubuntu.com/mirror.linux-ia64.org/g' /etc/apt/sources.list

useradd $1 -s /bin/bash -d /home/test
mkdir /home/test
chown -R test:test /home/test
echo ''$1'    ALL=(ALL:ALL) ALL' >> /etc/sudoers

usermod --password $(openssl passwd -6 $2) root
usermod --password $(openssl passwd -6 $2) $1


apt update
apt install htop
apt install sshpass
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
mv /etc/ansible/ansible.cfg /etc/ansible/ansible.cfg_orig
echo "[defaults]" > /etc/ansible/ansible.cfg
echo "host_key_checking = False" >> /etc/ansible/ansible.cfg

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

echo "*******************************************************************************"
echo "********************************* END *****************************************"
echo "*******************************************************************************"
echo "jenkins initial password"
cat /var/lib/jenkins/secrets/initialAdminPassword
echo "jenkins url"
echo 'http://'$5':8080'