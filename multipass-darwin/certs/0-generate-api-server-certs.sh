#!/usr/bin/env bash

KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local
KUBERNETES_IP=$(multipass list | grep controller-0 | awk '{print $3}')
NODE_0=$(multipass list | grep worker-0 | awk '{print $3}')
NODE_1=$(multipass list | grep worker-1 | awk '{print $3}')
NODE_2=$(multipass list | grep worker-2 | awk '{print $3}')



cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=10.32.0.1,${NODE_0},${NODE_1},${NODE_2},${KUBERNETES_IP},127.0.0.1,${KUBERNETES_HOSTNAMES} \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes