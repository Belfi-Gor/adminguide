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
usermod --password $(openssl passwd -6 $2) vagrant

# #Some packages may not be installed without vpn
# apt install openvpn -y
# systemctl disable openvpn
# #Configuration for Surfshark
# wget https://my.surfshark.com/vpn/api/v1/server/configurations -P /tmp/
# unzip /tmp/configurations -d /tmp/
# cp /tmp/104.200.132.35_tcp.ovpn /etc/openvpn/
# systemctl disable openvpn
# sed -i 's/auth-user-pass/auth-user-pass auth.conf/g' /etc/openvpn/104.200.132.35_tcp.ovpn
# # login
# echo '' >> /etc/openvpn/auth.conf
# #password
# echo '' >> /etc/openvpn/auth.conf

# #Create service which accept ovpn file in /etc/openvpn as external @ parameter
# #Создание сервиса который использует имя ovpn файла из /etc/openvpn как внешний @ параметр
# echo '[Unit]' > /lib/systemd/system/openvpn_custom@.service
# echo 'Description=OpenVPN connection to %i' >> /lib/systemd/system/openvpn_custom@.service
# echo 'After=network.target' >> /lib/systemd/system/openvpn_custom@.service
# echo '' >> /lib/systemd/system/openvpn_custom@.service
# echo '[Service]' >> /lib/systemd/system/openvpn_custom@.service
# echo 'Type=forking' >> /lib/systemd/system/openvpn_custom@.service
# echo 'ExecStart=/usr/sbin/openvpn --daemon ovpn-%i --status /run/openvpn/%i.status 10 --cd /etc/openvpn --config /etc/openvpn/%i.ovpn' >> /lib/systemd/system/openvpn_custom@.service
# echo 'ExecReload=/bin/kill -HUP $MAINPID' >> /lib/systemd/system/openvpn_custom@.service
# echo 'WorkingDirectory=/etc/openvpn' >> /lib/systemd/system/openvpn_custom@.service
# echo '' >> /lib/systemd/system/openvpn_custom@.service
# echo '[Install]' >> /lib/systemd/system/openvpn_custom@.service
# echo 'WantedBy=multi-user.target' >> /lib/systemd/system/openvpn_custom@.service
# echo 'openvpn@.service (END)' >> /lib/systemd/system/openvpn_custom@.service

# systemctl daemon-reload

# systemctl start openvpn_custom@104.200.132.35_tcp

if [ $3 == "true" ]; then apt upgrade -y; else echo '$3'=$3; fi

rm -Rf /etc/hosts

echo "127.0.0.1	localhost.localdomain	localhost" >> /etc/hosts
echo "$5	$4.localdomain	$4" >> /etc/hosts
echo "192.168.2.30 ceph1" >> /etc/hosts
echo "192.168.2.31 ceph2" >> /etc/hosts
echo "192.168.2.32 ceph3" >> /etc/hosts

apt update
apt install sshpass -y
apt install ntp -y
apt install lvm2 -y

fdisk -l
#(echo n; echo ""; echo ""; echo ""; echo ""; echo w) | fdisk /dev/sdb
#mkfs.ext4 /dev/sdb1
#mkdir /ceph-osd-1
#echo "/dev/sdb1 /ceph-osd-1 ext4 defaults 0 0" >> /etc/fstab
#mount -a

(echo ""; echo ""; echo "") | ssh-keygen


ssh-keyscan -H ceph1 >> ~/.ssh/known_hosts
sshpass -p 123456789 ssh-copy-id root@ceph1

ssh-keyscan -H ceph2 >> ~/.ssh/known_hosts
sshpass -p 123456789 ssh-copy-id root@ceph2

ssh-keyscan -H ceph3 >> ~/.ssh/known_hosts
sshpass -p 123456789 ssh-copy-id root@ceph3

if [[ $HOSTNAME = "ceph3" ]]
then
    #wget -q -O- 'https://download.ceph.com/keys/release.asc' | apt-key add -
    #apt install curl  apt-transport-https -y
    #curl https://mirror.croit.io/keys/release.gpg > /usr/share/keyrings/croit-signing-key.gpg
    #echo 'deb [signed-by=/usr/share/keyrings/croit-signing-key.gpg] https://mirror.croit.io/debian-mimic/ stretch main' > /etc/apt/sources.list.d/croit-ceph.list
    #apt install python3-pip -y
    #pip3 install git+https://github.com/ceph/ceph-deploy.git
    apt update
    #apt install ceph-deploy
    apt install python3-pip -y
    pip3 install ceph-deploy
    mkdir ceph-cluster
    ceph-deploy new ceph1 ceph2 ceph3
    echo "public network = 192.168.2.0/24" >> /home/vagrant/ceph-cluster/ceph.conf
    #echo "#cluster network = 192.168.3.0/24" >> /home/vagrant/ceph-cluster/ceph.conf

    ceph-deploy install ceph1 ceph2 ceph3
    ceph-deploy mon create-initial
    ceph-deploy admin ceph1 ceph2 ceph3
    ceph status
    ceph-deploy mgr create ceph1 ceph2 ceph3
    ceph-deploy admin ceph1 ceph2 ceph3
    ceph-deploy osd create --data /dev/sdb ceph1
    ceph-deploy osd create --data /dev/sdb ceph2
    ceph-deploy osd create --data /dev/sdb ceph3
	
	ceph auth add client.kube mon 'allow r' osd 'allow rwx pool=kube'
	echo "client.key:"
    ceph auth get-key client.kube
    echo ""
    echo "admin.key:"
	ceph auth get client.admin 2>&1 |grep "key = " |awk '{print  $3'}
fi

echo "*******************************************************************************"
echo "********************************* END *****************************************"
echo "*******************************************************************************"
#systemctl stop openvpn_custom@104.200.132.35_tcp
#systemctl disable openvpn_custom@104.200.132.35_tcp