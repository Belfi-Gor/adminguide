# repo override
#kz
#sed -i 's/us.archive.ubuntu.com/mirror.hoster.kz/g' /etc/apt/sources.list
#ru
sed -i 's/us.archive.ubuntu.com/mirror.linux-ia64.org/g' /etc/apt/sources.list

useradd $1 -s /bin/bash -d /home/test
mkdir /home/test
chown -R test:test /home/test
echo ''$1'    ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers

usermod --password $(openssl passwd -6 $2) root
usermod --password $(openssl passwd -6 $2) $1

echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJi1uiZXE74dfF4pWQGJQaFRww+BwJgNPmzP0moVQ9w+zO6GvI89tGPtKb8jVpDXHoTeytgA1t9LD0N5sYlbX0BE0z9p+UT8tG546ln8AUxLCNzV9tCpMOaNoC28C/d13/xlaY23STPFKjsCKD935K1/RdJIfJFz4S4NYhSJF5PqDSTB/xb69CQUozFMJyL3g7vyo3rjl7eMeCFzCEwihjhWzLlqkGlsCP1WuTKslHetitUnyPV2653C3SqOKCCUQS7lXMHYlvQAZXFtXz/hX5RL0s2UGWODh8uXidBoZpqKdjBQbMLh081lJZ4Pq6AQjhzN7MLUTQZAdMETYrs4pl vagrant' > /home/$1/.ssh/authorized_keys

apt update
apt install htop
if [ $3 == "true" ]; then apt upgrade -y; else echo '$3'=$3; fi

rm -Rf /etc/hosts

echo "127.0.0.1	localhost.localdomain	localhost" >> /etc/hosts
echo "$5	$4.localdomain	$4" >> /etc/hosts

echo "*******************************************************************************"
echo "********************************* END *****************************************"
echo "*******************************************************************************"

