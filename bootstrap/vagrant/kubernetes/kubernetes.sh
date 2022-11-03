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

if [ $3 == "true" ]; then apt upgrade -y; else echo '$3'=$3; fi

rm -Rf /etc/hosts

echo "127.0.0.1	localhost.localdomain	localhost" >> /etc/hosts
echo "$5	$4.localdomain	$4" >> /etc/hosts

echo "*******************************************************************************"
echo "************************** INSTALLING KUBERNETES ******************************"
echo "*******************************************************************************"
apt update && sudo apt install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
apt update
apt install -y kubelet kubeadm kubectl

echo "*******************************************************************************"
echo "***************************** INSTALLING DOCKER *******************************"
echo "*******************************************************************************"
apt install ca-certificates curl gnupg lsb-release -y
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

apt update

apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

echo "*******************************************************************************"
echo "************************* PREFLIGHTS CONFIGURATION ****************************"
echo "*******************************************************************************"
rm /etc/containerd/config.toml
systemctl restart containerd
swapoff -a
sed -i '/swap/d' /etc/fstab
mount -a
kubeadm config images pull



#kubeadm init
#export KUBECONFIG=/etc/kubernetes/admin.conf
#kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

#wget https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-4%2Bdebian11_all.deb
#dpkg -i zabbix-release_6.0-4+debian11_all.deb
#apt update 
#apt install zabbix-agent -y
#sed -i "s/Server=127.0.0.1/Server=$6/g" /etc/zabbix/zabbix_agentd.conf
#echo 'UserParameter=custom_echo[*],echo $1' >> /etc/zabbix/zabbix_agentd.conf
#echo 'UserParameter=my_script[*], python3 /etc/zabbix/test_python_script.py $1 $2' > /etc/zabbix/zabbix_agentd.d/test_user_parameter.conf
#systemctl restart zabbix-agent
#systemctl enable zabbix-agent

#if [[ ! -f /etc/zabbix/test_python_script.py ]]
#then
#    echo 'import sys' >> /etc/zabbix/test_python_script.py
#    echo 'import os' >> /etc/zabbix/test_python_script.py
#    echo 'import re' >> /etc/zabbix/test_python_script.py
#    echo 'if (sys.argv[1] == "-ping"): # Если -ping' >> /etc/zabbix/test_python_script.py
#    echo '        result=os.popen("ping -c 1 " + sys.argv[2]).read() # Делаем пинг по заданному адресу' >> /etc/zabbix/test_python_script.py
#    echo '        result=re.findall(r"time=(.*) ms", result) # Выдёргиваем из результата время' >> /etc/zabbix/test_python_script.py
#    echo '        print(result[0]) # Выводим результат в консоль' >> /etc/zabbix/test_python_script.py
#    echo 'elif (sys.argv[1] == "-simple_print"): # Если simple_print ' >> /etc/zabbix/test_python_script.py
#    echo '        print(sys.argv[2]) # Выводим в консоль содержимое sys.arvg[2]' >> /etc/zabbix/test_python_script.py
#    echo 'else: # Во всех остальных случаях' >> /etc/zabbix/test_python_script.py
#    echo '        print(f"unknown input: {sys.argv[1]}") # Выводим непонятый запрос в консоль.' >> /etc/zabbix/test_python_script.py
#fi


echo "*******************************************************************************"
echo "********************************* END *****************************************"
echo "*******************************************************************************"