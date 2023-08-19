#!/usr/bin/env bash

KUBERNETES_PUBLIC_ADDRESS=$(az network public-ip show -g kthw -n kubernetes-the-hard-way --query 'ipAddress' | jq -r .)
KUBERNETES_NLB_IP_ADDRESS=$(az network nic show -g kthw -n lb-nic --query "ipConfigurations[0].privateIPAddress" | jq -r .)

KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local


cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,${KUBERNETES_NLB_IP_ADDRESS},${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,${KUBERNETES_HOSTNAMES} \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes