#!/usr/bin/env bash

cd

echo "=================================================================================================================="
echo "Sending certificates, keys and config files to controller nodes"
echo "=================================================================================================================="
echo -e "\n"

for instance in controller-0 controller-1 controller-2; do
  echo "Copy certificates and keys..."
  scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem service-account-key.pem service-account.pem ${instance}:~/
  echo "Copy encryption-config.yaml"
  scp encryption-config.yaml ${instance}:~/
  echo -e "\n"
  scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig ${instance}:~/
done


echo "=================================================================================================================="
echo "Sending certificates, keys and config files to worker nodes"
echo "=================================================================================================================="
echo -e "\n"

for instance in worker-0 worker-1 worker-2; do
  echo "Copy client certificates"
  scp ca.pem ${instance}-key.pem ${instance}.pem ${instance}:~/

  echo "Copy kubelet and kube-proxy config files"
  scp ${instance}.kubeconfig kube-proxy.kubeconfig ${instance}:~/
done