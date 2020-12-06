# Table of Contents
This is a list of points that will be explained in this instructions file for the IKE project :

- [High-level Architecture](#high-level-architecture)
- [Prerequisites](#prerequisites)
- [Nodes Setup](#nodes-setup)
- [K8S Cluster Configuration](#k8s-cluster-configuration)
- [IKE Parameters](#ike-parameters)
- [Kubernetes deployment](#kubernetes-deployment)
- [Manage ETCD Cluster](./manage_etcd.md)
- [Create Pod](#create-pod)


# High-level Architecture

Below a diagram of the high-level architecture deployed by IKE :
![Architecture](../images/AgoraKube_diagram.png)

**Notes :** This distibution is aimed to be customizable so you can choose : 
 - Where the **etcd** will be deployed (with the master or not) 
 - The number of **master** nodes to deploy (from 1 to many - 5 nodes for production)
 - The number of **etcd** nodes to deploy (from 1 to many - 5 nodes for production)
 - The number of **worker** nodes to deploy (from 1 to many)
 - The number of **storage** nodes to deploy (from 0 to many - 3 nodes for production needs)
 
 # Prerequisites

This section explains what are the prerequisites to install IKE in your environment.

## OS

Below the OS currently supported on all the machines :
  - Ubuntu 18.04 & 20.04 - amd64
  - Centos 7 - amd64
  - Debian 10 - amd64

## Network

- Full network connectivity between all machines in the cluster (public or private network is fine)
- Full internet access
- Unique hostname, MAC address, and product_uuid for every node. See here for more [details](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#verify-the-mac-address-and-product-uuid-are-unique-for-every-node).
- Certain ports are open on your machines. See here for more [details](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#check-required-ports).

## Node Sizing

Node sizing indicated here is for production environment. You can custom it according to sweet your needs.

ETCD and MASTER are actually installed on the same Host, but it is a best-practice to install them on separate hosts.

| IKE Type | no HA or all-in-one | no-production | production |
| --- | --- | --- | --- |
| MASTER | 1 | 3 | 5 |
| ETCD | 1 | 3 | 5 |
| WORKER | 1 | X | X |
| STORAGE | 0 - 1 | 3 | 3+ |

We actually configure the proper VM size for your master depending on the number of nodes (Workers + Storage) in your cluster

| nodes | Master Size |
| --- | --- |
| 1-5 | 1 CPU - 3,75 Go RAM |
| 6-10 | 2 CPU - 7,50 Go RAM |
| 11-100 | 4 CPU - 15 Go RAM |
| 101-250 | 8 CPU - 30 Go RAM |
| 251-500 | 16 CPU - 60 Go RAM |
| more than 500 | 32 CPU - 120 Go RAM |

# Nodes Setup

This section explains how to setup notes before deploying Kubernetes Clusters with IKE.

## Deployment node

The deployment node is an Ansible server which contains all Ansible roles and variables used to deploy and configure Kubernetes Clusters with IKE distribution.

The prerequisites are:
- SSH Server (like openssh-server)
- Python3 & pip3
- Ansible
- netaddr
- git
- curl

Then clone or download the git branch / release you want to use.

You can run the following command to automatically install those packages and clone the latest stable IKE distribution:
```
bash <(curl -s https://raw.githubusercontent.com/ilkilab/ike-core/master/setup-deploy.sh)
```


## K8S nodes

The K8S nodes will host all the components needed for a Kubernetes cluster Control and Data planes.

The prerequisites are:
- SSH Server (like openssh-server)
- Python3
- curl

You can run the following command to automatically install those packages :
```
bash <(curl -s https://raw.githubusercontent.com/ilkilab/ike-core/master/setup-hosts.sh)
```

## SSH keys creation

IKE is using Ansible to deploy Kubernetes. You have to configure SSH keys to ensure the communication between the deploy machine and the others.

On the deploy machine, create the SSH keys :
```
ssh-keygen
```
You can let everything by default.

When your keys are created, you have to copy the public key in the other machine in the folder /home/yourUser/.ssh/authorized_keys, or you can use the following commands to copy the key :
```
ssh-copy-id -i .ssh/id_rsa.pub yourUser@IP_OF_THE_HOST
```
You have to execute this command for each node of your cluster

Once your ssh keys have been pushed to all nodes, modify the file "ike/hosts" to add the user/ssh-key (in section **SSH Connection settings**) that IKE will use to connect to all nodes

# K8S Cluster Configuration

IKE enables an easy way to deploy and manage customizable K8S clusters.

## Inventory file

The first file to modify is ["./hosts"](../hosts). This file contains all architecture information about your K8S Cluster.

**All K8S servers names must be filled in by their hostname**. You can run ```hostname -s``` to get it.

The next Sample deploys K8S components in HA mode on 6 nodes (3 **etcd/masters** nodes, 3 **workers** nodes) :

```
[deploy]
worker1 ansible_connection=local

[masters]
worker1  ansible_host=10.10.20.4

[etcd]
worker1  ansible_host=10.10.20.4

[workers]
worker2  ansible_host=10.10.20.5
worker3  ansible_host=10.10.20.6

[storage]
worker4 ansible_host=10.10.20.20

[all:vars]
advertise_masters=10.10.20.40
#advertise_masters=kubernetes.localcluster.lan

# SSH connection settings
ansible_ssh_extra_args='-o StrictHostKeyChecking=no'
ansible_user=vagrant
ansible_ssh_private_key_file=/home/vagrant/ssh-private-key.pem

[etc_hosts]
#kubernetes.localcluster.lan ansible_host=10.10.20.4
```

The **deploy** section contains information about how to connect to the deployment machine.

The **etcd** section contains information about the etcd machine(s) instances.

The **masters** section contains information about the masters nodes (K8S Control Plane).

The **workers** section contains information about the workers nodes (K8S Data Plane).

The **storage** section contains information about the storage nodes (K8S Storage Plane ).

The **etc_hosts** section contains a list of DNS entries that will be injected to /etc/hosts files of all hosts. Use it only if you don't have DNS server.

The **all:vars** section contains information about how to connect to K8S nodes.

The **advertise_masters** parameter configure the Advertising IP of control Plan. Actually it is the IP of a frontal LB that expose Master nodes on port TCP/6643. It can also be a Master's IP if you don't have LB. In this case, HA is not enabled even if you got multiple Masters...

The **SSH Connection settings** section contain information about the SSH connexion. You have to modify the variable **ansible_ssh_private_key_file** with the path where your public key is stored.
**ansible_user** User used as service account by Agorakube to connect to all nodes. **User must be sudoer**.

## Configuration file

The [../group_vars/all.yaml](../group_vars/all.yaml) file contains all configuration variables that you can customize to make your K8S Cluster fit your needs.

Sample file will deploy **containerd** as container runtime, **calico** as CNI plugin and enable all IKE features (storage, dashboard, monitoring, LB, ingress, ....).

```
---
ike:
  global:
    data_path: /var/ike

ike_pki:
  infos:
    state: "Ile-De-France"
    locality: "Paris"
    country: "FR"
    root_cn: "ILKI Kubernetes Engine"
    expirity: "+3650d"
  management:
    rotate_certificats: false

ike_base_components:
  etcd:
    release: v3.4.14
    update: false
    check: true
    data_path: /var/lib/etcd
  kubernetes:
    release: v1.19.4
    update: false
  container:
    engine: containerd
# release : Only Supported if container engine is set to docker
    release: ""
#    update: false

ike_network:
  cni_plugin: calico
  mtu: 0
  cidr:
    pod: 10.33.0.0/16
    service: 10.32.0.0/24
  service_ip:
    kubernetes: 10.32.0.1 
    coredns: 10.32.0.10
  nodeport:
    range: 30000-32000
  external_loadbalancing:
    enabled: True
    ip_range: 10.10.20.50-10.10.20.250
    secret_key: LGyt2l9XftOxEUIeFf2w0eCM7KjyQdkHform0gldYBKMORWkfQIsfXW0sQlo1VjJBB17shY5RtLg0klDNqNq4PAhNaub+olSka61LxV73KN2VaJY/snrZmHbdf/a7DfdzaeQ5pzP6D5O7zbUZwfb5ASOhNrG8aDMY3rkf4ZzHkc=
  kube_proxy:
    mode: ipvs
    algorithm: rr

ike_features:
  storage:
    enabled: true
    jiva:
      data_path: /var/openebs
      fs_type: ext4
    hostpath:
      data_path: /var/local-hostpath
  dashboard:
    enabled: true
    generate_admin_token: true
  metrics_server:
    enabled: true
  ingress:
    controller: nginx
    release: v0.41.2
  monitoring:
    enabled: true
    persistent: true
    admin:
      user: administrator
      password: P@ssw0rd

ike_populate_etc_hosts: True

# Security
ike_encrypt_etcd_keys:
# Warrning: If multiple keys are defined ONLY LAST KEY is used for encrypt and decrypt.
# Other keys are used only for decrypt purpose. Keys can be generated with command: head -c 32 /dev/urandom | base64
  key1:
    secret: 1fJcKt6vBxMt+AkBanoaxFF2O6ytHIkETNgQWv4b/+Q=

#restoration_snapshot_file: /path/snopshot/file Located on {{ etcd_data_directory }}

```

**Note :** You can also modify the IPs-CIDR if you want.

# IKE Parameters

Below  you can find all the parameters you can use in this file, section by section.

### Global Section

This section is used to custom global IKE settings.

| Parameter | Description | Values |
| --- | --- | --- |
| `ike.global.data_path` | Path where IKE saves all config/pik/service files on deploy machine | **/var/ike/** *(default)* |

### Certificates & PKI section

This section is used to custom the PKI used for your deployment and manage Certificates lifecycle.

| Parameter | Description | Values |
| --- | --- | --- |
| `ike_pki.infos.state` | State or province name added to PKI CSR | **Ile-De-France** *(default)* |
| `ike_pki.infos.locality` | Locality added to PKI CSR | **Paris** *(default)* |
| `ike_pki.infos.country` | Country added to PKI CSR | **FR** *(default)* |
| `ike_pki.infos.root_cn` | CommonName used for Root CA | **ILKI Kubernetes Engine** *(default)* |
| `ike_pki.infos.expirity` | Expirity for all PKI certificats | **+3650d** (default - 10 years)|
| `ike_pki.management.rotate_certificats` | Boolean used to rotate certificates | **False** (default)|

### IPs-CIDR Configurations

This section is used to custom network configurations of your deployment.

**Note :** It will depend on the CNI plugin used.

| Parameter | Description | Values |
| --- | --- | --- |
| `cluster_cidr` | CIDR used for all pods deployed in your cluster | <ul><li> **Depend on your deployment** </li><br/><li>  **10.33.0.0/16** *(default)* </li></ul>|
| `service_cluster_ip_range` | CIDR used for all services deployed in your cluster | <ul><li> **Depend on your deployment** </li><br/><li>   **10.32.0.0/16** *(default)* </li></ul>|
| `kubernetes_service` | IP used for Kubernetes service of your cluster. **Must be** the first IP of your service CIDR ! | <ul><li> **Depend on your deployment** </li><br/><li>  **10.32.0.1** *(default)* </li></ul>|
| `cluster_dns_ip` | IP used for DNS services deployed in your cluster | <ul><li> **Depend on your deployment** </li><br/><li>  **10.32.0.10** *(default)* </li></ul>|
| `service_node_port_range` | Range of ports used for all NodePort services deployed in your cluster | <ul><li> **depend on your deployment** </li><br/><li>   **30000-32767** *(default)* </li></ul>|
| `cni_release` | CNI release to use | <ul><li>  **0.8.6** *(default)* </li></ul>|
| `enable_metallb_layer2` | Enable MetalLB. This add Service type LoadBalancer support to Kubernetes | <ul><li> **Depend on your deployment** </li><br/><li>  **True** *(default)* </li></ul>|
| `metallb_layer2_ips` | IP range used by LoadBalancer Service  | <ul><li> **Depend on your deployment** </li><br/><li>  **10.100.200.10-10.100.200.250** *(default)* </li></ul>|
| `metallb_secret_key` | metallb_secret_key is generated with command : openssl rand -base64 128 | <ul><li> **Depend on your deployment** </li></ul>|

### Custom features section

This section is used to defined all custom features of your deployment.

| Parameter | Description | Values |
| --- | --- | --- |
| `runtime` | Container runtime used in your deployment | <ul><li> **containerd** *(default)* </li><br/><li>  **docker**  </li></ul>|
| `network_cni_plugin` | CNI plugin used in your deployment | <ul><li> **calico** </li><br/><li>  **kube-router** *(default)* </li></ul>|
| `ingress_controller` | Ingress Controller used in your deployment | <ul><li> **traefik** *(default)* </li><br/><li>  **ha-proxy**  </li><br/><li>  **nginx**  </li><br/><li>  **none**  </li></ul>|
| `populate_etc_hosts` | Populate */etc/hosts* file of all your nodes in the cluster | <ul><li> **no** </li><br/><li>  **yes** *(default)* </li></ul>|
| `k8s_dashboard` | Deploy Kubernetes dashboard in your cluster | <ul><li> **false** </li><br/><li>  **true** *(default)* </li></ul>|


### Other parameters sections

Parameters for etcd :

| Parameter | Description | Values |
| --- | --- | --- |
| `encrypt_etcd_keys` | Encryption keys used for etcd - Dictionary format | <ul><li> **Depend on your deployment** </li><br/><li>  **1fJcKt6vBxMt+AkBanoaxFF2O6ytHIkETNgQWv4b/+Q=** *(default)* </li></ul> |
| `check_etcd_install` | Display ETCD infos | <ul><li> **True** (Default) </li><br/><li>  False </li></ul> |

Parameters for Agorakube datas storage :

| Parameter | Description | Values |
| --- | --- | --- |
| `data_path` | Path to Agorakube datas directory | <ul><li> **Depend on your deployment** </li><br/><li> **"/var/agorakube"** *(default)* </li></ul> |

Parameters for etcd data location, and backups

| Parameter | Description | Values |
| --- | --- | --- |
| `etcd_data_directory` | Directory to store etcd data on **etcd members** | <ul><li> **/var/lib/etcd/** (default) </li><br/></ul> |
| `custom_etcd_backup_dir` | Directory where etcd leader backups are stored on **deploy** node | <ul><li> **{{data_path}}/backups_etcd/** (default if not defined) </li><br/></ul> |
| `restoration_snapshot_file` | Path to the etcd snapshot on **deploy** node | <ul><li> **not defined** (default) </li><br/></ul> |


Monitoring Settings

| Parameter | Description | Values |
| --- | --- | --- |
| `enable_monitoring` | Deploy monitoring - Warrning : **Rook Must be enabled !** | <ul><li> **False** (default) </li><br/><li>  **true** </li></ul> |

# Kubernetes deployment

Once all configuration files are set, run the following command to launch the Ansible playbook that will deploy the pre-configured Kubernetes cluster :

```
sudo ansible-playbook agorakube.yaml
```

# Create pod<a name="create-pod" />

After the pre-configured Kubernetes cluster is deployed, run the following command to deploy a sample Kubernetes pod with the busybox image:

```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: busybox-sleep
spec:
  containers:
  - name: busybox
    image: busybox
    args:
    - sleep
    - "1000"
EOF
```

You should see an output similar to this:

```
pod/busybox-sleep created
```

Run the following command to verify if the deployed pod is running:

```
kubectl get pods
```


