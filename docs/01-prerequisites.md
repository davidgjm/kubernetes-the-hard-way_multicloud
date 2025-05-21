# Prerequisites

In this lab you will review the machine requirements necessary to follow this tutorial.

## Virtual or Physical Machines

This tutorial requires four (4) virtual or physical ARM64 or AMD64 machines running Debian 12 (bookworm). The following table lists the four machines and their CPU, memory, and storage requirements.

| Name    | Description            | CPU | RAM   | Storage |
|---------|------------------------|-----|-------|---------|
| jumpbox | Administration host    | 1   | 512MB | 10GB    |
| controller-0  | Kubernetes server      | 1   | 2GB   | 20GB    |
| controller-1  | Kubernetes server      | 1   | 2GB   | 20GB    |
| controller-2  | Kubernetes server      | 1   | 2GB   | 20GB    |
| node-0  | Kubernetes worker node | 1   | 2GB   | 20GB    |
| node-1  | Kubernetes worker node | 1   | 2GB   | 20GB    |
| node-2  | Kubernetes worker node | 1   | 2GB   | 20GB    |

How you provision the machines is up to you, the only requirement is that each machine meet the above system requirements including the machine specs and OS version. Once you have all four machines provisioned, verify the OS requirements by viewing the `/etc/os-release` file:

```bash
cat /etc/os-release
```

You should see something similar to the following output:

```text
PRETTY_NAME="Debian GNU/Linux 12 (bookworm)"
NAME="Debian GNU/Linux"
VERSION_ID="12"
VERSION="12 (bookworm)"
VERSION_CODENAME=bookworm
ID=debian
```


### Example Configuration

| Role                    |              DNS Name | IP Address     |
| ----------------------- | --------------------: | -------------- |
| jump server             | jumpserver01.home.lab | 172.16.100.200 |
| Load Balancer (haproxy) |          k8s.home.lab | 172.16.100.21  |
| Controller 1            | controller-0.home.lab | 172.16.100.210 |
| Controller 2            | controller-1.home.lab | 172.16.100.211 |
| Controller 3            | controller-2.home.lab | 172.16.100.212 |
| Node 1                  |       node-0.home.lab | 172.16.100.220 |
| Node 2                  |       node-1.home.lab | 172.16.100.221 |
| Node 3                  |       node-2.home.lab | 172.16.100.222 |


Next: [setting-up-the-jumpbox](02-jumpbox.md)
