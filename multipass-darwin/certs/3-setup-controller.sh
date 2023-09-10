#!/usr/bin/env bash

INTERNAL_IP=$(echo -n `hostname -I| tr -d '\n'`)
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

sed -i -e "s/\${ENCRYPTION_KEY}/$ENCRYPTION_KEY/" encryption-config.yaml
sudo mv ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
  service-account-key.pem service-account.pem \
  encryption-config.yaml /var/lib/kubernetes/


echo "Setting up api server..."
sudo mv kube-apiserver.service /etc/systemd/system/
sudo sed -i -e "s/\${KUBERNETES_IP}/$KUBERNETES_IP/" /etc/systemd/system/kube-apiserver.service

echo -e "\n"

echo "Setting up kube-controller-manager..."
sudo mv kube-controller-manager.kubeconfig /var/lib/kubernetes/
sudo mv kube-controller-manager.service /etc/systemd/system/
echo -e "\n"

echo "Setting up kube-scheduler..."
sudo mv kube-scheduler.kubeconfig /var/lib/kubernetes/
sudo mv kube-scheduler.yaml /etc/kubernetes/config/kube-scheduler.yaml
sudo mv kube-scheduler.service /etc/systemd/system/kube-scheduler.service
echo -e "\n"

echo "Setting up systemd services..."
{
  sudo systemctl daemon-reload
  sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler
  sudo systemctl start kube-apiserver kube-controller-manager kube-scheduler
}

echo -e "\n"
echo "Enable HTTP Health Checks"
cat > kubernetes.default.svc.cluster.local <<EOF
server {
  listen      80;
  server_name kubernetes.default.svc.cluster.local;

  location /healthz {
     proxy_pass                    https://127.0.0.1:6443/healthz;
     proxy_ssl_trusted_certificate /var/lib/kubernetes/ca.pem;
  }
}
EOF

sudo mv kubernetes.default.svc.cluster.local \
  /etc/nginx/sites-available/kubernetes.default.svc.cluster.local

sudo ln -s /etc/nginx/sites-available/kubernetes.default.svc.cluster.local /etc/nginx/sites-enabled/

sudo systemctl restart nginx
sudo systemctl enable nginx

kubectl cluster-info --kubeconfig admin.kubeconfig
curl -H "Host: kubernetes.default.svc.cluster.local" -i http://127.0.0.1/healthz


echo -e "\n"
echo RBAC for Kubelet Authorization
kubectl apply --kubeconfig admin.kubeconfig -f kube-apiserver-to-kubelet.yaml
kubectl apply --kubeconfig admin.kubeconfig -f kube-apiserver-rb.yaml
