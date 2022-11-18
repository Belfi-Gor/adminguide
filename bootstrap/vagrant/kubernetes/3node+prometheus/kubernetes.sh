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
echo "192.168.2.40 kube-master-1" >> /etc/hosts
echo "192.168.2.41 kube-slave-1" >> /etc/hosts
echo "192.168.2.42 kube-slave-2" >> /etc/hosts

apt update
apt install sshpass -y
apt install net-tools -y

echo "*******************************************************************************"
echo "************************ PREPARING KEYS FOW MASTER ****************************"
echo "*******************************************************************************"

(echo ""; echo ""; echo "") | ssh-keygen

ssh-keyscan -H kube-slave-2 >> ~/.ssh/known_hosts
sshpass -p 123456789 ssh-copy-id root@kube-slave-2

ssh-keyscan -H kube-slave-1 >> ~/.ssh/known_hosts
sshpass -p 123456789 ssh-copy-id root@kube-slave-1

ssh-keyscan -H kube-master-1 >> ~/.ssh/known_hosts
sshpass -p 123456789 ssh-copy-id root@kube-master-1

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

if [[ $HOSTNAME = "kube-master-1" ]]
then
  echo "*******************************************************************************"
  echo "************************ 3 NODE CLUSTER CONFIGURATION *************************"
  echo "*******************************************************************************"
  kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=192.168.2.40
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh

  export KUBEADMJOINCOMMAND=$(kubeadm token create --print-join-command)

  echo "******************************* ADDING SLAVE 1 ********************************"
  ssh root@kube-slave-1 $KUBEADMJOINCOMMAND
  echo "******************************* ADDING SLAVE 2 ********************************"
  ssh root@kube-slave-2 $KUBEADMJOINCOMMAND
  #kubectl taint nodes --all node-role.kubernetes.io/control-plane-

  #https://artifacthub.io/packages/helm/mesosphere/prometheus-operator
  # helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  # helm repo add stable https://charts.helm.sh/stable
  # helm repo update
  # helm install netology-prometheus-demo prometheus-community/kube-prometheus-stack
fi

echo "*******************************************************************************"
echo "***************************** POSTCONFIGURATION *******************************"
echo "*******************************************************************************"

echo "*******************************************************************************"
echo "********************************* END *****************************************"
echo "*******************************************************************************"