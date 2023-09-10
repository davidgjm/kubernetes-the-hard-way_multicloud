#!/usr/bin/env bash

vm_user=ubuntu

echo "================================================================================================================="
echo "Sending certificates, keys and config files to controller nodes"
echo "================================================================================================================="
echo -e "\n"

instance=$(multipass list | grep controller-0 | awk '{print $3}')
echo "Copy certificates and keys..."
scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem service-account-key.pem service-account.pem ${vm_user}@${instance}:~/

echo "Copy quick setup script"
scp 2-setup-etcd.sh 3-setup-controller.sh ${vm_user}@${instance}:~/
echo -e "\n"

scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig ${vm_user}@${instance}:~/

echo "copy controller config files"
scp ../etc/controller/* ${vm_user}@${instance}:~/
scp ../deployments/*.yaml ${vm_user}@${instance}:~/
echo -e "\n"



echo "================================================================================================================="
echo "Sending certificates, keys and config files to worker nodes"
echo "================================================================================================================="
echo -e "\n"
for instance in worker-0 worker-1 worker-2; do
  NODE_IP=$(multipass list | grep $instance | awk '{print $3}')
  echo "Copy client certificates"
  scp ca.pem ${instance}-key.pem ${instance}.pem ${vm_user}@${NODE_IP}:~/

  echo "Copy worker setup script"
  scp 3-setup-worker.sh ${vm_user}@${NODE_IP}:~/

  echo "Copy kubelet and kube-proxy config files"
  scp ${instance}.kubeconfig kube-proxy.kubeconfig ${vm_user}@${NODE_IP}:~/

  echo -e "\n"
  echo "Copy worker config files"
  scp ../etc/worker/* ${vm_user}@${NODE_IP}:~/
done