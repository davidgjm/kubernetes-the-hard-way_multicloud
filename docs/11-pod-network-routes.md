# Provisioning Pod Network Routes

Pods scheduled to a node receive an IP address from the node's Pod CIDR range. At this point pods can not communicate with other pods running on different nodes due to missing network [routes](https://cloud.google.com/compute/docs/vpc/routes).

In this lab you will create a route for each worker node that maps the node's Pod CIDR range to the node's internal IP address.

> There are [other ways](https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-achieve-this) to implement the Kubernetes networking model.

## The Routing Table

In this section you will gather the information required to create routes in the `kubernetes-the-hard-way` VPC network.

Print the internal IP address and Pod CIDR range for each worker instance:

```bash
{
  CONTROLLER_0_IP=$(grep controller-0 machines.txt | cut -d " " -f 1)
  CONTROLLER_1_IP=$(grep controller-1 machines.txt | cut -d " " -f 1)
  CONTROLLER_1_IP=$(grep controller-2 machines.txt | cut -d " " -f 1)
  NODE_0_IP=$(grep node-0 machines.txt | cut -d " " -f 1)
  NODE_0_SUBNET=$(grep node-0 machines.txt | cut -d " " -f 4)
  NODE_1_IP=$(grep node-1 machines.txt | cut -d " " -f 1)
  NODE_1_SUBNET=$(grep node-1 machines.txt | cut -d " " -f 4)
  NODE_2_IP=$(grep node-2 machines.txt | cut -d " " -f 1)
  NODE_2_SUBNET=$(grep node-2 machines.txt | cut -d " " -f 4)
}
```

```bash

for controller in controller-0 controller-1 controller-2; do
ssh ${controller} <<EOF
  sudo ip route add ${NODE_0_SUBNET} via ${NODE_0_IP}
  sudo ip route add ${NODE_1_SUBNET} via ${NODE_1_IP}
  sudo ip route add ${NODE_2_SUBNET} via ${NODE_2_IP}
EOF
done

```

```bash
ssh node-0 <<EOF
  sudo ip route add ${NODE_1_SUBNET} via ${NODE_1_IP}
  sudo ip route add ${NODE_2_SUBNET} via ${NODE_2_IP}
EOF
```

```bash
ssh node-1 <<EOF
  sudo ip route add ${NODE_0_SUBNET} via ${NODE_0_IP}
  sudo ip route add ${NODE_2_SUBNET} via ${NODE_2_IP}
EOF
```

```bash
ssh node-2 <<EOF
  sudo ip route add ${NODE_0_SUBNET} via ${NODE_0_IP}
  sudo ip route add ${NODE_1_SUBNET} via ${NODE_1_IP}
EOF
```

## Verification 

```bash
ssh controller-0 ip route
```

```text
default via 172.16.100.1 dev eth0 proto dhcp src 172.16.100.210 metric 100
10.200.0.0/24 via 172.16.100.220 dev eth0
10.200.1.0/24 via 172.16.100.221 dev eth0
10.200.2.0/24 via 172.16.100.222 dev eth0
172.16.100.0/24 dev eth0 proto kernel scope link src 172.16.100.210 metric 100
172.16.100.1 dev eth0 proto dhcp scope link src 172.16.100.210 metric 100
172.31.255.2 via 172.16.100.1 dev eth0 proto dhcp src 172.16.100.210 metric 100
```

```bash
ssh node-0 ip route
```

```text
default via 172.16.100.1 dev eth0 proto dhcp src 172.16.100.220 metric 100
10.200.1.0/24 via 172.16.100.221 dev eth0
10.200.2.0/24 via 172.16.100.222 dev eth0
172.16.100.0/24 dev eth0 proto kernel scope link src 172.16.100.220 metric 100
172.16.100.1 dev eth0 proto dhcp scope link src 172.16.100.220 metric 100
172.31.255.2 via 172.16.100.1 dev eth0 proto dhcp src 172.16.100.220 metric 100
```

```bash
ssh node-1 ip route
```

```text
default via 172.16.100.1 dev eth0 proto dhcp src 172.16.100.221 metric 100
10.200.0.0/24 via 172.16.100.220 dev eth0
10.200.2.0/24 via 172.16.100.222 dev eth0
172.16.100.0/24 dev eth0 proto kernel scope link src 172.16.100.221 metric 100
172.16.100.1 dev eth0 proto dhcp scope link src 172.16.100.221 metric 100
172.31.255.2 via 172.16.100.1 dev eth0 proto dhcp src 172.16.100.221 metric 100
```

```bash
ssh node-2 ip route
```

```text
default via 172.16.100.1 dev eth0 proto dhcp src 172.16.100.222 metric 100
10.200.0.0/24 via 172.16.100.220 dev eth0
10.200.1.0/24 via 172.16.100.221 dev eth0
172.16.100.0/24 dev eth0 proto kernel scope link src 172.16.100.222 metric 100
172.16.100.1 dev eth0 proto dhcp scope link src 172.16.100.222 metric 100
172.31.255.2 via 172.16.100.1 dev eth0 proto dhcp src 172.16.100.222 metric 100
```


Next: [Smoke Test](12-smoke-test.md)
