# Provisioning a CA and Generating TLS Certificates

In this lab you will provision a [PKI Infrastructure](https://en.wikipedia.org/wiki/Public_key_infrastructure) using CloudFlare's PKI toolkit, [cfssl](https://github.com/cloudflare/cfssl), then use it to bootstrap a Certificate Authority, and generate TLS certificates for the following components: etcd, kube-apiserver, kube-controller-manager, kube-scheduler, kubelet, and kube-proxy.

## Pre-populated `cfssl` files
Some configuration files as well as csr files for `cfssl` have been already created and available. Those files can be found under *certs* directory.

You're free to edit these files or completely ignore and use your own trusted ones when you perform the certificate below.

## Certificate Authority

In this section you will provision a Certificate Authority that can be used to generate additional TLS certificates.

Generate the CA configuration file, certificate, and private key:

```shell
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
```

Results:

```
ca-key.pem
ca.pem
```

## Client and Server Certificates

In this section you will generate client and server certificates for each Kubernetes component and a client certificate for the Kubernetes `admin` user.

### The Admin Client Certificate

Generate the `admin` client certificate and private key:

```shell
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin

```

Results:

```
admin-key.pem
admin.pem
```

### The Kubelet Client Certificates

Kubernetes uses a [special-purpose authorization mode](https://kubernetes.io/docs/reference/access-authn-authz/node/) called Node Authorizer, that specifically authorizes API requests made by [Kubelets](https://kubernetes.io/docs/concepts/overview/components/#kubelet). In order to be authorized by the Node Authorizer, Kubelets must use a credential that identifies them as being in the `system:nodes` group, with a username of `system:node:<nodeName>`. In this section you will create a certificate for each Kubernetes worker node that meets the Node Authorizer requirements.

Generate a certificate and private key for each Kubernetes worker node:

```shell
for instance in worker-0 worker-1 worker-2; do


INTERNAL_IP=$(az vm list-ip-addresses -g kthw -n ${instance} \
  --query '[0].virtualMachine.network.privateIpAddresses[0])')

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${instance},${INTERNAL_IP} \
  -profile=kubernetes \
  ${instance}-csr.json | cfssljson -bare ${instance}
done
```

Results:

```
worker-0-key.pem
worker-0.pem
worker-1-key.pem
worker-1.pem
worker-2-key.pem
worker-2.pem
```

### The Controller Manager Client Certificate

Generate the `kube-controller-manager` client certificate and private key:

```shell

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

```

Results:

```
kube-controller-manager-key.pem
kube-controller-manager.pem
```


### The Kube Proxy Client Certificate

Generate the `kube-proxy` client certificate and private key:

```shell
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy
```

Results:

```
kube-proxy-key.pem
kube-proxy.pem
```

### The Scheduler Client Certificate

Generate the `kube-scheduler` client certificate and private key:

```shell
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-scheduler-csr.json | cfssljson -bare kube-scheduler
```

Results:

```
kube-scheduler-key.pem
kube-scheduler.pem
```


### The Kubernetes API Server Certificate

The `kubernetes-the-hard-way` static IP address will be included in the list of subject alternative names for the Kubernetes API Server certificate. This will ensure the certificate can be validated by remote clients.

Generate the Kubernetes API Server certificate and private key:

```shell
{

KUBERNETES_PUBLIC_ADDRESS=$(az network public-ip show -g kthw -n kubernetes-the-hard-way --query 'ipAddress')

KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local


cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,${KUBERNETES_HOSTNAMES} \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes

}
```

```shell
# ../certs/generate-api-server-certs.sh
```

> The Kubernetes API server is automatically assigned the `kubernetes` internal dns name, which will be linked to the first IP address (`10.32.0.1`) from the address range (`10.32.0.0/24`) reserved for internal cluster services during the [control plane bootstrapping](08-bootstrapping-kubernetes-controllers.md#configure-the-kubernetes-api-server) lab.

Results:

```
kubernetes-key.pem
kubernetes.pem
```

## The Service Account Key Pair

The Kubernetes Controller Manager leverages a key pair to generate and sign service account tokens as described in the [managing service accounts](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/) documentation.

Generate the `service-account` certificate and private key:

```shell
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  service-account-csr.json | cfssljson -bare service-account

```

Results:

```
service-account-key.pem
service-account.pem
```


## Distribute the Client and Server Certificates

As the load balancer VM is the only VM exposed to the internet, we will need to copy all resources into this machine and distribute from there.


### Setup load balancer vm

#### Login the load balancer VM
```
➜  infra git:(azure) ✗ ssh azureuser@xx.xxx.xxx.xx
The authenticity of host 'xx.xxx.xxx.xx (xx.xxx.xxx.xx)' can't be established.
ED25519 key fingerprint is SHA256:41/qOH8bVtrBrJTmPoPQP2GvX5AmjnNOOXcYKcliBVg.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'xx.xxx.xxx.xx' (ED25519) to the list of known hosts.
Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 5.15.0-1042-azure x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Sun Aug 13 12:27:51 UTC 2023

  System load:  0.0               Processes:             111
  Usage of /:   6.4% of 28.89GB   Users logged in:       0
  Memory usage: 4%                IPv4 address for eth0: 10.240.0.244
  Swap usage:   0%

Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

1 additional security update can be applied with ESM Apps.
Learn more about enabling ESM Apps service at https://ubuntu.com/esm



The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.```

azureuser@lb-vm:~$
```

#### Copy ssh private key to the load balancer

```shell
scp ../infra/id_vm azureuser@xx.xxx.xxx.xx:~/.ssh/id_rsa
scp ../infra/id_vm.pub azureuser@xx.xxx.xxx.xx:~/.ssh/id_rsa.pub
```

```shell
ssh azureuser@xx.xxx.xxx.xx "chmod 400 ~/.ssh/id_rsa*"
```

#### 


### Copy to API Server load balancer

#### Copy the appropriate certificates and private keys for worker instances

```shell
scp ca.pem worker-*.pem azureuser@xx.xxx.xxx.xx:~/
```

Results:
```
ca.pem
worker-0-key.pem
worker-0.pem
worker-1-key.pem
worker-1.pem
worker-2-key.pem
worker-2.pem
```

##### Copy to worker nodes
```shell
for instance in worker-0 worker-1 worker-2; do
  scp ca.pem ${instance}-key.pem ${instance}.pem ${instance}:~/
done
```


### Copy the appropriate certificates and private keys for controller instances

#### Copy to load balancer node
```
scp ca.pem ca-key.pem service-account*.pem kubernetes*.pem azureuser@xx.xxx.xxx.xx:~/
```

Results:
```
ca.pem
ca-key.pem
kubernetes-key.pem
kubernetes.pem
```


### Copy files to controller nodes
```shell

for instance in controller-0 controller-1 controller-2; do
  scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem ${instance}:~/
done
```

> The `kube-proxy`, `kube-controller-manager`, `kube-scheduler`, and `kubelet` client certificates will be used to generate client authentication configuration files in the next lab.

Next: [Generating Kubernetes Configuration Files for Authentication](05-kubernetes-configuration-files.md)
