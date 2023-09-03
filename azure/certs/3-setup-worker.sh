#!/usr/bin/env bash

echo Configure CNI networking
sudo cp 99-loopback.conf /etc/cni/net.d/99-loopback.conf
echo -e "\n"

echo Configure containerd
sudo cp containerd-config.toml /etc/containerd/config.toml
sudo cp containerd.service /etc/systemd/system/containerd.service
sudo cp crictl.yaml /etc/crictl.yaml
echo -e "\n"

echo Configure the Kubelet
sudo mv ${HOSTNAME}-key.pem ${HOSTNAME}.pem /var/lib/kubelet/
sudo mv ${HOSTNAME}.kubeconfig /var/lib/kubelet/kubeconfig
sudo mv ca.pem /var/lib/kubernetes/

cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
cgroupDriver: systemd
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/${HOSTNAME}.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/${HOSTNAME}-key.pem"
EOF

sudo cp kubelet.service /etc/systemd/system/kubelet.service
echo -e "\n"

echo Configure the Kubernetes Proxy
sudo mv kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig
sudo cp kube-proxy-config.yaml /var/lib/kube-proxy/kube-proxy-config.yaml
sudo cp kube-proxy.service /etc/systemd/system/kube-proxy.service
echo -e "\n"

echo Setting up systemctl unit services...
{
  sudo systemctl daemon-reload
  sudo systemctl enable containerd kubelet kube-proxy
  sudo systemctl start containerd kubelet kube-proxy
}
echo -e "\n"
echo -e "\n"
echo -e "\n"
echo -e "\n"