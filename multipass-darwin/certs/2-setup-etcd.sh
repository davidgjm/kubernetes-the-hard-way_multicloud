#!/usr/bin/env bash

sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/
INTERNAL_IP=$(echo -n `hostname -I| tr -d '\n'`)
ETCD_NAME=$(hostname -s)

sed -e "s/\${ETCD_NAME}/$ETCD_NAME/" -e "s/\${INTERNAL_IP}/$INTERNAL_IP/" etcd.service | sudo tee /etc/systemd/system/etcd.service

sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd
sleep 2

sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem \
  -w table
