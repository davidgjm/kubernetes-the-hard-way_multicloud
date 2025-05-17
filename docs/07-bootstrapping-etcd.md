# Bootstrapping the etcd Cluster

Kubernetes components are stateless and store cluster state in [etcd](https://github.com/etcd-io/etcd). In this lab you will bootstrap a single node etcd cluster.

## Prerequisites

Copy `etcd` binaries and systemd unit files to the `server` machine:

```bash
for controller in controller-0 controller-1 controller-2; do
  scp \
    downloads/controller/etcd \
    downloads/client/etcdctl \
    units/${controller}_etcd.service \
    ${controller}:~/etcd-files/
  ssh ${controller} sudo mv ~/etcd-files/* /root
  ssh ${controller} sudo chown -R root: /root/
  ssh ${controller} sudo mv /root/${controller}_etcd.service /root/etcd.service
done
```

The commands in this lab must be run on the `server` machine. Login to the `server` machine using the `ssh` command. Example:

```bash
ssh root@server
```

## Bootstrapping an etcd Cluster

### Install the etcd Binaries

Change to `root` user 
```shell
sudo su -
```

Extract and install the `etcd` server and the `etcdctl` command line utility:

```bash
{
  mv etcd etcdctl /usr/local/bin/
}
```

### Configure the etcd Server

```bash
{
  mkdir -p /etc/etcd /var/lib/etcd
  chmod 700 /var/lib/etcd
  cp ca.crt kube-api-server.key kube-api-server.crt \
    /etc/etcd/
}
```

Each etcd member must have a unique name within an etcd cluster. Set the etcd name to match the hostname of the current compute instance:

Create the `etcd.service` systemd unit file:

```bash
mv etcd.service /etc/systemd/system/
```

### Start the etcd Server

```bash
{
  systemctl daemon-reload
  systemctl enable etcd
  systemctl start etcd
}
```

## Verification

List the etcd cluster members:

```bash
etcdctl member list
```

```text
6702b0a34e2cfd39, started, controller, http://127.0.0.1:2380, http://127.0.0.1:2379, false
```

### etcd cluster

List the etcd cluster members:

```shell
ENDPOINTS=172.16.100.210:2379,172.16.100.211:2379,172.16.100.212:2379
ETCD_OPTIONS="--endpoints=https://127.0.0.1:2379 --cacert=/etc/etcd/ca.crt --cert=/etc/etcd/kube-api-server.crt --key=/etc/etcd/kube-api-server.key"


etcdctl --endpoints=$ENDPOINTS $ETCD_OPTIONS member list
```


Check cluster status
```shell
etcdctl --endpoints=$ENDPOINTS $ETCD_OPTIONS endpoint --cluster status -w table
```

```text
+-----------------------------+------------------+------------+-----------------+---------+--------+-----------------------+-------+-----------+------------+-----------+------------+--------------------+--------+--------------------------+-------------------+
|          ENDPOINT           |        ID        |  VERSION   | STORAGE VERSION | DB SIZE | IN USE | PERCENTAGE NOT IN USE | QUOTA | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS | DOWNGRADE TARGET VERSION | DOWNGRADE ENABLED |
+-----------------------------+------------------+------------+-----------------+---------+--------+-----------------------+-------+-----------+------------+-----------+------------+--------------------+--------+--------------------------+-------------------+
| https://172.16.100.211:2379 | 47d7b34efa3bc239 | 3.6.0-rc.3 |           3.6.0 |   20 kB |  16 kB |                   20% |   0 B |     false |      false |         2 |         19 |                 19 |        |                          |             false |
| https://172.16.100.212:2379 | 55c95e0ca3ba103d | 3.6.0-rc.3 |           3.6.0 |   20 kB |  16 kB |                   20% |   0 B |      true |      false |         2 |         19 |                 19 |        |                          |             false |
| https://172.16.100.210:2379 | c982d1b0e095604e | 3.6.0-rc.3 |           3.6.0 |   20 kB |  16 kB |                   20% |   0 B |     false |      false |         2 |         19 |                 19 |        |                          |             false |
+-----------------------------+------------------+------------+-----------------+---------+--------+-----------------------+-------+-----------+------------+-----------+------------+--------------------+--------+--------------------------+-------------------+

```


Next: [Bootstrapping the Kubernetes Control Plane](08-bootstrapping-kubernetes-controllers.md)
