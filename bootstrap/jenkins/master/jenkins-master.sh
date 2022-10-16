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
echo "-----BEGIN OPENSSH PRIVATE KEY-----" > /var/lib/jenkins/.ssh/id_rsa
echo "b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn" >> /var/lib/jenkins/.ssh/id_rsa
echo "NhAAAAAwEAAQAAAYEAumK8xkVkOseZGRFTKF8ghAt8xE2GOuQa/Ye3z2M2XivsSJfORHBI" >> /var/lib/jenkins/.ssh/id_rsa
echo "5z9kV9cQ+gqpYOYZ4UzeNxX5BWsqnOSmSQrJLIkXR2Dd7BTW+CqNUBHcGD04SqrPHGhzEG" >> /var/lib/jenkins/.ssh/id_rsa
echo "rrB+utugg42n6pF8Jfw3bICcdkShFLV5MCRxIJP5EHNIv4hK9K85YZ7KJmSKNV/lXXszyW" >> /var/lib/jenkins/.ssh/id_rsa
echo "cN9aTUu+dhH0/7P7ERfAp/rnQEKpIA7i9yG6Na+Mg6uTN+RA3Vr3PMagddWVp/8H3eLI6d" >> /var/lib/jenkins/.ssh/id_rsa
echo "Ex5HRDclBHlfh6nCQWnJ2LgiTBxDIvXMJ7OWEehuquSk6Ld16aeWNDufNXBzIoq+0CKJgP" >> /var/lib/jenkins/.ssh/id_rsa
echo "9Wsi9369RlNDiK0bvuSF1T/5IoZjjcLPwOYUwBgURJEkYWdFi6sQ55njjG6ihxGZmjYYhl" >> /var/lib/jenkins/.ssh/id_rsa
echo "x1cHhiUVeQUOkHa2ESrIT9N1xc+4miUdcCgU742zx+AFriNpGnwzl/+qIUUKyiPxeZV2Wu" >> /var/lib/jenkins/.ssh/id_rsa
echo "iMYGJgZXMPGFkalPK3jzPMWFzUTJI3yTE+xZ2etpAAAFkH5w6NV+cOjVAAAAB3NzaC1yc2" >> /var/lib/jenkins/.ssh/id_rsa
echo "EAAAGBALpivMZFZDrHmRkRUyhfIIQLfMRNhjrkGv2Ht89jNl4r7EiXzkRwSOc/ZFfXEPoK" >> /var/lib/jenkins/.ssh/id_rsa
echo "qWDmGeFM3jcV+QVrKpzkpkkKySyJF0dg3ewU1vgqjVAR3Bg9OEqqzxxocxBq6wfrrboION" >> /var/lib/jenkins/.ssh/id_rsa
echo "p+qRfCX8N2yAnHZEoRS1eTAkcSCT+RBzSL+ISvSvOWGeyiZkijVf5V17M8lnDfWk1LvnYR" >> /var/lib/jenkins/.ssh/id_rsa
echo "9P+z+xEXwKf650BCqSAO4vchujWvjIOrkzfkQN1a9zzGoHXVlaf/B93iyOnRMeR0Q3JQR5" >> /var/lib/jenkins/.ssh/id_rsa
echo "X4epwkFpydi4IkwcQyL1zCezlhHobqrkpOi3demnljQ7nzVwcyKKvtAiiYD/VrIvd+vUZT" >> /var/lib/jenkins/.ssh/id_rsa
echo "Q4itG77khdU/+SKGY43Cz8DmFMAYFESRJGFnRYurEOeZ44xuoocRmZo2GIZcdXB4YlFXkF" >> /var/lib/jenkins/.ssh/id_rsa
echo "DpB2thEqyE/TdcXPuJolHXAoFO+Ns8fgBa4jaRp8M5f/qiFFCsoj8XmVdlrojGBiYGVzDx" >> /var/lib/jenkins/.ssh/id_rsa
echo "hZGpTyt48zzFhc1EySN8kxPsWdnraQAAAAMBAAEAAAGBAIgE1ITRUTMARL8hgJFe0qjqhT" >> /var/lib/jenkins/.ssh/id_rsa
echo "Pw63uAyh2pdL+5RIz2+umDN3mEg/+WqJDeF7qSG0fmxI5B/Y0v0NpeeeujhaKaZ3PD3CQw" >> /var/lib/jenkins/.ssh/id_rsa
echo "EeRe1P6odxYu4nMiAjmja5/srcQWcs0F9nNj2rHBa382T5Ki1ZslUxAmjNgtJaVeCTfFi/" >> /var/lib/jenkins/.ssh/id_rsa
echo "+SAlw6XLVlHigt3/00jeYdGVvpZFSc+xabpzQdKLGO1DOGJQexuB+SRkBp/MKjb3QMV7wj" >> /var/lib/jenkins/.ssh/id_rsa
echo "cz1/qsKfxvwobCNyKlQ+bWs9jMIypenAKnQY/duPHJY5bLYzjvdiGmj8goftTdBEZ0Hurf" >> /var/lib/jenkins/.ssh/id_rsa
echo "hKhKp9jfsvF8Kg2f4h1rEF/NsrFg94qWaGvUJ4EPDdiOwfX6pgnKEVTZp3B8VnfkJ9M8mo" >> /var/lib/jenkins/.ssh/id_rsa
echo "cFO766szWGp4phJj6Ba4HUD/N8V3kHC3PmHeqPrI1qzBh4RfJNzOMjQOj/RfvCx5B6Nbeh" >> /var/lib/jenkins/.ssh/id_rsa
echo "XBcnXVvL4VWNV2GF4DSgvTBXXujW0nYPHkUJef35l1kC/FibclNsneaa8DxAvE1cS+zQAA" >> /var/lib/jenkins/.ssh/id_rsa
echo "AMEAuioNfUvqf1jMZUCjY/gFPsQ+3U3HWqjJgdBVkqsqiVZKZsQQJ1xglfC1r5BVJEcNhJ" >> /var/lib/jenkins/.ssh/id_rsa
echo "yA9Ut7Ts2yZBlh+NGI9Mw+mCmxGMri+wVV5SSyfBYNCs8iDJoOifAoe3UjUdZfJx8h7MJI" >> /var/lib/jenkins/.ssh/id_rsa
echo "xp+LaxJ4lmlSXA9vDFCdDLdBNm+fpGRRSqEvHauxpx5S5FP5VjfRe+LB4lrbmAjh5pPEEE" >> /var/lib/jenkins/.ssh/id_rsa
echo "4ol1Smx97v+tMg9vYxS+yIKRXYtzgGFUgCxV7Wx23c19RHWVhIAAAAwQD1slUlo8EsVQjW" >> /var/lib/jenkins/.ssh/id_rsa
echo "KQAWUKB39rf7PiFA1zWzzSdFjqJBFQPFePSrQo9MZK1y0Q55ZDY3iLfmTFCg02cjcWr/2E" >> /var/lib/jenkins/.ssh/id_rsa
echo "JoJgJoPi5V6w4WTj8JBEbzf65M+LD53pusb94oon86Bzvaxt7rqEKN/O3Ia9YEBUcJmVoC" >> /var/lib/jenkins/.ssh/id_rsa
echo "sXiF3FjzQmEQFspBrNVn7w1DgDx58nCvlc41KpEYYSQziGgtJAAy+BCcbn7uq+OaPKdRpR" >> /var/lib/jenkins/.ssh/id_rsa
echo "4QI9LFJUSIfmTG/kNXTihxBUrGm4jICTsAAADBAMIzrKvilq7qQL9+k1OLe3/v7V2PEY6a" >> /var/lib/jenkins/.ssh/id_rsa
echo "66Eb0M0Qb5sUhSHFOf+w8qPhU/q9zjG5RByg0CKVRue8WHltsHTmp1o43K9fY80e2gQcAH" >> /var/lib/jenkins/.ssh/id_rsa
echo "++ZmfkAKes0UXnTooYHFYnOozuUOkrjC7cRng/UNBF045nUIdXiRtZWQoOZxE/J+/MpnV8" >> /var/lib/jenkins/.ssh/id_rsa
echo "EGYmjadXDecW4gn842sky/8jS5GFmnS5lapARad+XcRLBKlSpmdJWmv6h+P1nC706uVwmd" >> /var/lib/jenkins/.ssh/id_rsa
echo "jpM0xCsUvWyN8zqwAAABZqZW5raW5zQGplbmtpbnMtbWFzdGVyAQID" >> /var/lib/jenkins/.ssh/id_rsa
echo "-----END OPENSSH PRIVATE KEY-----" >> /var/lib/jenkins/.ssh/id_rsa

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6YrzGRWQ6x5kZEVMoXyCEC3zETYY65Br9h7fPYzZeK+xIl85EcEjnP2RX1xD6Cqlg5hnhTN43FfkFayqc5KZJCsksiRdHYN3sFNb4Ko1QEdwYPThKqs8caHMQausH6626CDjafqkXwl/DdsgJx2RKEUtXkwJHEgk/kQc0i/iEr0rzlhnsomZIo1X+VdezPJZw31pNS752EfT/s/sRF8Cn+udAQqkgDuL3Ibo1r4yDq5M35EDdWvc8xqB11ZWn/wfd4sjp0THkdENyUEeV+HqcJBacnYuCJMHEMi9cwns5YR6G6q5KTot3Xpp5Y0O581cHMiir7QIomA/1ayL3fr1GU0OIrRu+5IXVP/kihmONws/A5hTAGBREkSRhZ0WLqxDnmeOMbqKHEZmaNhiGXHVweGJRV5BQ6QdrYRKshP03XFz7iaJR1wKBTvjbPH4AWuI2kafDOX/6ohRQrKI/F5lXZa6IxgYmBlcw8YWRqU8rePM8xYXNRMkjfJMT7FnZ62k= jenkins@"$4 > /var/lib/jenkins/.ssh/id_rsa.pub


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