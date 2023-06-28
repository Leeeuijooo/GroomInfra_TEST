#!/bin/bash
sudo apt-update
sleep 5
echo "apt-update 완료"

sudo curl -ssL https://get.docker.com/ | bash
sleep 10
echo "docker 설치 완료"

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sleep 3
echo "kubectl release download completed"

curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
sleep 3
echo "kubectl checksum file download completed"

echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sleep 3
echo "Validate kubectl binaries through checksum file_kubectl: OK"

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
sleep 3
echo "kubectl install completed"

kubectl version --client --output=yaml
sleep 1
echo "kubectl version completed"


sudo apt-get -y install unzip
sleep 5
echo "unzip install completed"

sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sleep 4
echo "awscli install completed"

sudo unzip awscliv2.zip
sleep 25
echo "unzip awscli completed"

sudo ./aws/install
sleep 4
echo "aws install "

sudo  /usr/local/bin/aws --version
echo "aws version completed"


REGION="ap-northeast-2"
sleep 1
aws configure set aws_access_key_id "your key"
sleep 1
aws configure set aws_secret_access_key "your key"
aws configure set region ${REGION}
sleep 2
echo "update kubeconfig"
aws eks --region ap-northeast-2 update-kubeconfig --name eks_name
sleep 3
kubectl get nodes
