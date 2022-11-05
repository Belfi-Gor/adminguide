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

echo "*******************************************************************************"
echo "********************** ONE NODE CLUSTER CONFIGURATION *************************"
echo "*******************************************************************************"
kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=192.168.2.30
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

echo "*******************************************************************************"
echo "************************** POSTGRESQL + PV EXAMPLE ****************************"
echo "*******************************************************************************"
echo 'kind: StorageClass' > /home/test/storage.yaml
echo 'apiVersion: storage.k8s.io/v1' >> /home/test/storage.yaml
echo 'metadata:' >> /home/test/storage.yaml
echo '  name: local-storage' >> /home/test/storage.yaml
echo 'provisioner: kubernetes.io/no-provisioner' >> /home/test/storage.yaml
echo 'volumeBindingMode: WaitForFirstConsumer' >> /home/test/storage.yaml

kubectl apply -f /home/test/storage.yaml
mkdir -p /devkube/postgresql


echo 'apiVersion: v1' > /home/test/pv.yaml
echo 'kind: PersistentVolume' >> /home/test/pv.yaml
echo 'metadata:' >> /home/test/pv.yaml
echo '  name: pv-for-pg' >> /home/test/pv.yaml
echo '  labels:' >> /home/test/pv.yaml
echo '    type: local' >> /home/test/pv.yaml
echo 'spec:' >> /home/test/pv.yaml
echo '  capacity:' >> /home/test/pv.yaml
echo '    storage: 4Gi' >> /home/test/pv.yaml
echo '  volumeMode: Filesystem' >> /home/test/pv.yaml
echo '  accessModes:' >> /home/test/pv.yaml
echo '  - ReadWriteOnce' >> /home/test/pv.yaml
echo '  persistentVolumeReclaimPolicy: Retain' >> /home/test/pv.yaml
echo '  storageClassName: local-storage' >> /home/test/pv.yaml
echo '  local:' >> /home/test/pv.yaml
echo '    path: /devkube/postgresql' >> /home/test/pv.yaml
echo '  nodeAffinity:' >> /home/test/pv.yaml
echo '    required:' >> /home/test/pv.yaml
echo '      nodeSelectorTerms:' >> /home/test/pv.yaml
echo '      - matchExpressions:' >> /home/test/pv.yaml
echo '        - key: kubernetes.io/hostname' >> /home/test/pv.yaml
echo '          operator: In' >> /home/test/pv.yaml
echo '          values:' >> /home/test/pv.yaml
echo '          - kube-master-1' >> /home/test/pv.yaml

kubectl apply -f /home/test/pv.yaml


echo 'kind: PersistentVolumeClaim' > /home/test/pvc.yaml
echo 'apiVersion: v1' >> /home/test/pvc.yaml
echo 'metadata:' >> /home/test/pvc.yaml
echo '  name: pg-pvc' >> /home/test/pvc.yaml
echo 'spec:' >> /home/test/pvc.yaml
echo '  storageClassName: "local-storage"' >> /home/test/pvc.yaml
echo '  accessModes:' >> /home/test/pvc.yaml
echo '  - ReadWriteOnce' >> /home/test/pvc.yaml
echo '  resources:' >> /home/test/pvc.yaml
echo '    requests:' >> /home/test/pvc.yaml
echo '      storage: 4Gi' >> /home/test/pvc.yaml

kubectl apply -f /home/test/pvc.yaml

helm repo add bitnami https://charts.bitnami.com/bitnami

helm install dev-pg bitnami/postgresql --set primary.persistence.existingClaim=pg-pvc,auth.postgresPassword=pgpass


echo "*******************************************************************************"
echo "***************************** POSTCONFIGURATION *******************************"
echo "*******************************************************************************"
echo "After finish login and run to connect to psql"
echo 'kubectl run dev-pg-postgresql-client --rm --tty -i --restart="Never" --namespace default --image docker.io/bitnami/postgresql:14.2.0-debian-10-r22 --env="PGPASSWORD=pgpass"       --command -- psql --host dev-pg-postgresql -U postgres -d postgres -p 5432'


# export POSTGRES_PASSWORD=$(kubectl get secret --namespace default dev-pg-postgresql -o jsonpath="{.data.postgres-password}" | base64 --decode)
# kubectl run dev-pg-postgresql-client --rm --tty -i --restart='Never' --namespace default --image docker.io/bitnami/postgresql:14.2.0-debian-10-r22 --env="PGPASSWORD=$POSTGRES_PASSWORD"       --command -- psql --host dev-pg-postgresql -U postgres -d postgres -p 5432





echo "*******************************************************************************"
echo "********************************* END *****************************************"
echo "*******************************************************************************"