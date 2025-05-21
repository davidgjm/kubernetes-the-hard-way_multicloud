# Smoke Test

In this lab you will complete a series of tasks to ensure your Kubernetes cluster is functioning correctly.

## Data Encryption

In this section you will verify the ability to [encrypt secret data at rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#verifying-that-data-is-encrypted).

Create a generic secret:

```bash
kubectl create secret generic kubernetes-the-hard-way \
  --from-literal="mykey=mydata"
```

Print a hexdump of the `kubernetes-the-hard-way` secret stored in etcd:

```bash
ssh controller-0 \
    'etcdctl get /registry/secrets/default/kubernetes-the-hard-way | hexdump -C'


ssh controller-0 <<EOF
  export ENDPOINTS=172.16.100.210:2379,172.16.100.211:2379,172.16.100.212:2379
  export ETCD_OPTIONS="--endpoints=https://127.0.0.1:2379 --cacert=/etc/etcd/ca.crt --cert=/etc/etcd/kube-api-server.crt --key=/etc/etcd/kube-api-server.key"
  sudo etcdctl --endpoints=\$ENDPOINTS \$ETCD_OPTIONS get /registry/secrets/default/kubernetes-the-hard-way | hexdump -C
EOF
```

```text
00000000  2f 72 65 67 69 73 74 72  79 2f 73 65 63 72 65 74  |/registry/secret|
00000010  73 2f 64 65 66 61 75 6c  74 2f 6b 75 62 65 72 6e  |s/default/kubern|
00000020  65 74 65 73 2d 74 68 65  2d 68 61 72 64 2d 77 61  |etes-the-hard-wa|
00000030  79 0a 6b 38 73 3a 65 6e  63 3a 61 65 73 63 62 63  |y.k8s:enc:aescbc|
00000040  3a 76 31 3a 6b 65 79 31  3a 99 c8 ef 1d a6 ed c9  |:v1:key1:.......|
00000050  21 40 da d2 70 e9 c8 34  3e 32 bc b9 7b 20 ae 8c  |!@..p..4>2..{ ..|
00000060  8b ba 21 e9 11 ba 4d 13  ad 80 a0 16 fd aa a9 55  |..!...M........U|
00000070  1f 55 05 4e 84 f3 ed 83  0b 51 0f c2 04 0d 34 fd  |.U.N.....Q....4.|
00000080  13 4f fd 3c 17 08 07 5d  b8 8e 64 30 3b 1c 1e c5  |.O.<...]..d0;...|
00000090  f6 9a 73 56 e4 1d a8 46  8e 59 8a 2f 95 bc 53 c7  |..sV...F.Y./..S.|
000000a0  47 1d cf 4a b4 76 3a 74  93 10 e5 8f 19 f1 22 a9  |G..J.v:t......".|
000000b0  a6 22 38 f0 5d 66 cc d2  7d 1b 2c 6d ac 6f a7 81  |."8.]f..}.,m.o..|
000000c0  1a d9 9c cf 76 63 2d 50  80 e2 ed 0f 80 02 cb 20  |....vc-P....... |
000000d0  af 66 c0 45 46 02 35 09  da de 8a d0 84 04 d6 96  |.f.EF.5.........|
000000e0  e6 86 e8 0f be 16 df bd  53 cf df 8c 27 f9 d6 1c  |........S...'...|
000000f0  b2 2b 82 19 b7 a2 6b 24  e1 a9 ff 15 00 e7 fb f8  |.+....k$........|
00000100  e7 53 82 0e 75 a2 88 0f  cc e0 ed 62 e6 7d 54 f1  |.S..u......b.}T.|
00000110  ae c8 b9 88 dc 43 bf 15  fc cd ad f2 70 e0 a7 45  |.....C......p..E|
00000120  06 c5 f3 8d 9b 83 f5 56  f0 39 8d 5a 49 48 5e 9b  |.......V.9.ZIH^.|
00000130  84 7d 5a fc af 35 79 47  fd 43 e6 6f b1 7f 43 4b  |.}Z..5yG.C.o..CK|
00000140  2b 7b 51 c3 b6 63 64 8e  00 34 48 a9 e9 da 53 ff  |+{Q..cd..4H...S.|
00000150  00 84 cd 97 8b f2 d0 fc  2e 0a                    |..........|
0000015a
```

The etcd key should be prefixed with `k8s:enc:aescbc:v1:key1`, which indicates the `aescbc` provider was used to encrypt the data with the `key1` encryption key.

## Deployments

In this section you will verify the ability to create and manage [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).

Create a deployment for the [nginx](https://nginx.org/en/) web server:

```bash
kubectl create deployment nginx \
  --image=nginx:latest
```

List the pod created by the `nginx` deployment:

```bash
kubectl get pods -l app=nginx
```

```bash
NAME                     READY   STATUS    RESTARTS   AGE
nginx-56fcf95486-c8dnx   1/1     Running   0          8s
```

### Port Forwarding

In this section you will verify the ability to access applications remotely using [port forwarding](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/).

Retrieve the full name of the `nginx` pod:

```bash
POD_NAME=$(kubectl get pods -l app=nginx \
  -o jsonpath="{.items[0].metadata.name}")
```

Forward port `8080` on your local machine to port `80` of the `nginx` pod:

```bash
kubectl port-forward $POD_NAME 8080:80
```

```text
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
```

In a new terminal make an HTTP request using the forwarding address:

```bash
curl --head http://127.0.0.1:8080
```

```text
HTTP/1.1 200 OK
Server: nginx/1.27.4
Date: Sun, 06 Apr 2025 17:17:12 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Wed, 05 Feb 2025 11:06:32 GMT
Connection: keep-alive
ETag: "67a34638-267"
Accept-Ranges: bytes
```

Switch back to the previous terminal and stop the port forwarding to the `nginx` pod:

```text
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080
^C
```

### Logs

In this section you will verify the ability to [retrieve container logs](https://kubernetes.io/docs/concepts/cluster-administration/logging/).

Print the `nginx` pod logs:

```bash
kubectl logs $POD_NAME
```

```text
...
127.0.0.1 - - [06/Apr/2025:17:17:12 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.88.1" "-"
```

### Exec

In this section you will verify the ability to [execute commands in a container](https://kubernetes.io/docs/tasks/debug-application-cluster/get-shell-running-container/#running-individual-commands-in-a-container).

Print the nginx version by executing the `nginx -v` command in the `nginx` container:

```bash
kubectl exec -ti $POD_NAME -- nginx -v
```

```text
nginx version: nginx/1.27.4
```

## Services

In this section you will verify the ability to expose applications using a [Service](https://kubernetes.io/docs/concepts/services-networking/service/).

Expose the `nginx` deployment using a [NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport) service:

```bash
kubectl expose deployment nginx \
  --port 80 --type NodePort
```

> The LoadBalancer service type can not be used because your cluster is not configured with [cloud provider integration](https://kubernetes.io/docs/getting-started-guides/scratch/#cloud-provider). Setting up cloud provider integration is out of scope for this tutorial.

Retrieve the node port assigned to the `nginx` service:

```bash
NODE_PORT=$(kubectl get svc nginx \
  --output=jsonpath='{range .spec.ports[0]}{.nodePort}')
```

Retrieve the hostname of the node running the `nginx` pod:

```bash
NODE_NAME=$(kubectl get pods \
  -l app=nginx \
  -o jsonpath="{.items[0].spec.nodeName}")
```

Make an HTTP request using the IP address and the `nginx` node port:

```bash
curl -I http://${NODE_NAME}:${NODE_PORT}
```

```text
Server: nginx/1.27.4
Date: Sun, 06 Apr 2025 17:18:36 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Wed, 05 Feb 2025 11:06:32 GMT
Connection: keep-alive
ETag: "67a34638-267"
Accept-Ranges: bytes
```

Next: [Cleaning Up](13-cleanup.md)
