# repo override
#kz
#sed -i 's/us.archive.ubuntu.com/mirror.hoster.kz/g' /etc/apt/sources.list
#ru
sed -i 's/us.archive.ubuntu.com/mirror.linux-ia64.org/g' /etc/apt/sources.list

sed -i 's/#DNS=/DNS=192.168.10.254/g' /etc/systemd/resolved.conf


useradd test -s /bin/bash -d /home/test
mkdir /home/test
chown -R test:test /home/test
echo 'test    ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

usermod --password $(openssl passwd -6 123456789) root
usermod --password $(openssl passwd -6 123456789) test

apt update

echo "*******************************************************************************"
echo "********************** INSTALLING INITIAL PACKAGES ****************************"
echo "*******************************************************************************"

apt install htop -y
apt install sshpass -y

echo "*******************************************************************************"
echo "**************************** PRE CONFIGURATION ********************************"
echo "*******************************************************************************"

rm -Rf /etc/hosts
echo "127.0.0.1	localhost.localdomain	localhost" >> /etc/hosts

echo "*******************************************************************************"
echo "********************************* END *****************************************"
echo "*******************************************************************************"
