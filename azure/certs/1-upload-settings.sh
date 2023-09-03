#!/usr/bin/env bash

KUBERNETES_PUBLIC_ADDRESS=$(az network public-ip show -g kthw -n kubernetes-the-hard-way --query 'ipAddress' | jq -r .)
VM_USER=azureuser
RHOST=$VM_USER@$KUBERNETES_PUBLIC_ADDRESS
echo "Load Balancer instance: $RHOST"

echo "=================================================================================================================="
echo "Uploading ssh keys for connecting to other machines from load balancer..."
echo "=================================================================================================================="
scp ../infra/id_vm $RHOST:~/.ssh/id_rsa
scp ../infra/id_vm.pub $RHOST:~/.ssh/id_rsa.pub
ssh $RHOST "chmod 400 ~/.ssh/id_rsa*"

echo "Uploading distribution script to load balancer"
scp 2-distribute-files.sh $RHOST:~/

echo "Uploading NLB config file"
nlb_config=nlb-nginx.conf
scp ../etc/$nlb_config $RHOST:~/
ssh $RHOST "sudo cp -f $nlb_config /etc/nginx/nginx.conf"


echo "Uploading quick setup files..."
echo -e "\n"
scp 3-*.sh $RHOST:~/

echo "=================================================================================================================="
echo "Uploading certificates, keys and config files for controller nodes"
echo "=================================================================================================================="
echo -e "\n"
echo "Uploading keys/certificates..."
scp ca.pem ca-key.pem service-account*.pem kubernetes*.pem $RHOST:~/
echo -e "\n"

echo "Uploading kube-controller-manager and kube-scheduler kubeconfig files..."
scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig $RHOST:~/

echo "Uploading encryption-config.yaml for controller nodes..."
scp encryption-config.yaml $RHOST:~/
echo -e "\n"

echo "Uploading controller config files..."
scp ../etc/controller/* $RHOST:~/controller-config-files
echo -e "\n"

echo "=================================================================================================================="
echo "Uploading certificates, keys and config files for worker nodes"
echo "=================================================================================================================="
echo -e "\n"
echo "Copying certificates and keys for worker instances"
scp ca.pem worker-*.pem $RHOST:~/

echo "Uploading kubelet and kube-proxy kubeconfig files..."
scp worker-*.kubeconfig kube-proxy.kubeconfig $RHOST:~/

echo -e "\n"
echo "Uploading configuration files for worker nodes..."
scp ../etc/worker/* $RHOST:~/worker-config-files