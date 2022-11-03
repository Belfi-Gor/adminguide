# repo override
#kz
#sed -i 's/us.archive.ubuntu.com/mirror.hoster.kz/g' /etc/apt/sources.list
#ru
sed -i 's/us.archive.ubuntu.com/mirror.linux-ia64.org/g' /etc/apt/sources.list

useradd $1 -s /bin/bash -d /home/test
mkdir /home/test
chown -R test:test /home/test
echo ''$1'    ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

usermod --password $(openssl passwd -6 $2) root
usermod --password $(openssl passwd -6 $2) $1


apt update
apt install htop -y
apt install sshpass -y
apt install unzip -y
apt install software-properties-common gnupg2 curl -y

#Some packages may not be installed without vpn
apt install openvpn -y
systemctl disable openvpn
#Configuration for Surfshark
wget https://my.surfshark.com/vpn/api/v1/server/configurations -P /tmp/
unzip /tmp/configurations -d /tmp/
cp /tmp/104.200.132.35_tcp.ovpn /etc/openvpn/
systemctl disable openvpn
sed -i 's/auth-user-pass/auth-user-pass auth.conf/g' /etc/openvpn/104.200.132.35_tcp.ovpn
# login
echo '' >> /etc/openvpn/auth.conf
#password
echo '' >> /etc/openvpn/auth.conf

#Create service which accept ovpn file in /etc/openvpn as external @ parameter
#Создание сервиса который использует имя ovpn файла из /etc/openvpn как внешний @ параметр
echo '[Unit]' > /lib/systemd/system/openvpn_custom@.service
echo 'Description=OpenVPN connection to %i' >> /lib/systemd/system/openvpn_custom@.service
echo 'After=network.target' >> /lib/systemd/system/openvpn_custom@.service
echo '' >> /lib/systemd/system/openvpn_custom@.service
echo '[Service]' >> /lib/systemd/system/openvpn_custom@.service
echo 'Type=forking' >> /lib/systemd/system/openvpn_custom@.service
echo 'ExecStart=/usr/sbin/openvpn --daemon ovpn-%i --status /run/openvpn/%i.status 10 --cd /etc/openvpn --config /etc/openvpn/%i.ovpn' >> /lib/systemd/system/openvpn_custom@.service
echo 'ExecReload=/bin/kill -HUP $MAINPID' >> /lib/systemd/system/openvpn_custom@.service
echo 'WorkingDirectory=/etc/openvpn' >> /lib/systemd/system/openvpn_custom@.service
echo '' >> /lib/systemd/system/openvpn_custom@.service
echo '[Install]' >> /lib/systemd/system/openvpn_custom@.service
echo 'WantedBy=multi-user.target' >> /lib/systemd/system/openvpn_custom@.service
echo 'openvpn@.service (END)' >> /lib/systemd/system/openvpn_custom@.service

systemctl daemon-reload

systemctl start openvpn_custom@104.200.132.35_tcp

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
echo "************************* INSTALLING TERRAFORM ********************************"
echo "*******************************************************************************"
curl https://apt.releases.hashicorp.com/gpg | gpg --dearmor > hashicorp.gpg
install -o root -g root -m 644 hashicorp.gpg /etc/apt/trusted.gpg.d/
apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update
apt install terraform


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

systemctl stop openvpn_custom@104.200.132.35_tcp
systemctl disable openvpn_custom@104.200.132.35_tcp