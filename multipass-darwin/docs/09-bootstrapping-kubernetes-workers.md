# Bootstrapping the Kubernetes Worker Nodes

In this lab you will bootstrap three Kubernetes worker nodes. The following components will be installed on each node: [runc](https://github.com/opencontainers/runc), [container networking plugins](https://github.com/containernetworking/cni), [containerd](https://github.com/containerd/containerd), [kubelet](https://kubernetes.io/docs/admin/kubelet), and [kube-proxy](https://kubernetes.io/docs/concepts/cluster-administration/proxies).

## Prerequisites

The commands in this lab must be run on each worker instance: `worker-0`, `worker-1`, and `worker-2`. Login to each worker instance through load balancer. Example:

```
ssh worker-0
```

### Running commands in parallel with tmux

[tmux](https://github.com/tmux/tmux/wiki) can be used to run commands on multiple compute instances at the same time. See the [Running commands in parallel with tmux](01-prerequisites.md#running-commands-in-parallel-with-tmux) section in the Prerequisites lab.

## Provisioning a Kubernetes Worker Node


> The socat binary enables support for the `kubectl port-forward` command.


### Download and Install Worker Binaries

> The binaries are already downloaded through `cloud-init` script.
 

### Configure CNI Networking

Create the `loopback` network configuration file:
```shell
sudo cp 99-loopback.conf /etc/cni/net.d/99-loopback.conf
```

### Configure containerd

#### Create the `containerd` configuration file:

Copy the configuration file from home directory
```shell
sudo mv containerd-config.toml /etc/containerd/config.toml
```

> To see the default configuration, do `containerd config default >> containerd-defaults.toml`


#### Create the `containerd.service` systemd unit file:
```shell
sudo mv containerd.service /etc/systemd/system/containerd.service
```

#### Configure `crictl`
```shell
sudo mv crictl.yaml /etc/crictl.yaml
```

### Configure the Kubelet

```shell

sudo mv ${HOSTNAME}-key.pem ${HOSTNAME}.pem /var/lib/kubelet/
sudo mv ${HOSTNAME}.kubeconfig /var/lib/kubelet/kubeconfig
sudo mv ca.pem /var/lib/kubernetes/

```

#### Create the `kubelet-config.yaml` configuration file:

```
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
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
cgroupDriver: systemd
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/${HOSTNAME}.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/${HOSTNAME}-key.pem"
EOF
```

> The `resolvConf` configuration is used to avoid loops when using CoreDNS for service discovery on systems running `systemd-resolved`. 

#### Create the `kubelet.service` systemd unit file:
```shell
sudo mv kubelet.service /etc/systemd/system/kubelet.service
```

### Configure the Kubernetes Proxy

```
sudo mv kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig
```

Create the `kube-proxy-config.yaml` configuration file:

```shell
sudo mv kube-proxy-config.yaml /var/lib/kube-proxy/kube-proxy-config.yaml
```


Create the `kube-proxy.service` systemd unit file:

```shell
sudo mv kube-proxy.service /etc/systemd/system/kube-proxy.service
```

### Start the Worker Services

```
{
  sudo systemctl daemon-reload
  sudo systemctl enable containerd kubelet kube-proxy
  sudo systemctl start containerd kubelet kube-proxy
}
```

> Remember to run the above commands on each worker node: `worker-0`, `worker-1`, and `worker-2`.

## Verification

> The compute instances created in this tutorial will not have permission to complete this section. Run the following commands from the same machine used to create the compute instances.

List the registered Kubernetes nodes:

```
kubectl get nodes --kubeconfig admin.kubeconfig
```

> output

```
NAME       STATUS   ROLES    AGE   VERSION
worker-0   Ready    <none>   22s   v1.21.0
worker-1   Ready    <none>   22s   v1.21.0
worker-2   Ready    <none>   22s   v1.21.0
```

Next: [Configuring kubectl for Remote Access](10-configuring-kubectl.md)
