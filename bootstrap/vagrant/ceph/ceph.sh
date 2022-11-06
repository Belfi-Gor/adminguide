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

if [ $3 == "true" ]; then apt upgrade -y; else echo '$3'=$3; fi

rm -Rf /etc/hosts

echo "127.0.0.1	localhost.localdomain	localhost" >> /etc/hosts
echo "$5	$4.localdomain	$4" >> /etc/hosts

fdisk -l
(echo n; echo ""; echo ""; echo ""; echo ""; echo w) | fdisk /dev/sdb
mkfs.ext4 /dev/sdb1
mkdir /ceph-osd-1
echo "/dev/sdb1 /ceph-osd-1 ext4 defaults 0 0" >> /etc/fstab
mount -a

(echo ""; echo ""; echo "") | ssh-keygen


echo "*******************************************************************************"
echo "********************************* END *****************************************"
echo "*******************************************************************************"