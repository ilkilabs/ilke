# ILKI KUBERNETES ENGINE Core

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)


This project is aimed to provide the simplest way to install kubernetes on AMD-64 bare-metal, virtual & Cloud environments.
Currently, Ubuntu 18.04 & 20.04,  Centos 7 and Debian 10  are supported, but several other operating systems will be available soon.

Master branch is stable.

## Table of Contents

This is a list of points that will be explained in this Readme file for the IKE project :

- [What is IKE](#what-is-ike)
- [How to install](#how-to-install)
- [How to give feedback](#how-to-give-feedback)
- [How to contribute](#how-to-contribute)
- [Community](#community)
- [Licensing](#licensing)

## What is IKE

IKE is an easy-to-use, stable Kubernetes distribution (Kubernetes v1.15, 1.16, 1.17, 1.18, 1.19, 1.20).

By its symplicity, IKE provide a good way to deploy and manage K8S Clusters.

IKE is based on Ansible scripts that install and configure Kubernetes components (control plane and data plane) quickly on bare-metal / VMs / Cloud Instances, as systemd services.

This distribution is also adaptive by offering the opportunity to customize your deployment and fit to your needs : 
* OS : Ubuntu-18.04/20.04-amd64 and Centos 7.X-amd64, Debian-10-amd64 
* DNS Service: CoreDNS
* Ingress Controller Traefik v2 & HA-Proxy & Nginx (Default)
* Container Runtime: Containerd (Default) & Docker
* Certificats: Self Signed PKI using OpenSSL
* Storage: OpenEBS (Jiva and HostPath).
* Monitoring: Prometheus/Grafana/node-Exporter
* CNI plugin: Kube-router, Calico (VxLAN Cross-Subnet)
* MetalLB (L2/ARP mode for external LB)
* Metrics-Server
* Kubernetes-Dashboard

This project is currently under active development so other customizable options will be added soon.

## How to install

We regularly use a machine to deploy every cluster. We only use it for deployment.

### Setup

#### On the "deployment" node
Execute this command in order to install Ansible and clone the repository :
```
bash <(curl -s https://raw.githubusercontent.com/ilkilabs/ike-core/master/setup-deploy.sh)
```
#### On the K8S nodes
Execute this command on each node to update them and install the last version of Python : 
```
bash <(curl -s https://raw.githubusercontent.com/ilkilabs/ike-core/master/setup-hosts.sh)
```

### Installation instructions

To deploy your K8S cluster follow these [instructions](docs/instructions.md).

## How to give feedback

Every feedback is very welcome via the
[GitHub site](https://github.com/ilkilabs/ike-core)
as issues or pull (merge) requests.

You can also give use vulnerability reports by this way.
## How to contribute


See our [Code Of Conduct](https://github.com/ilkilabs/ike-core/blob/core/CODE_OF_CONDUCT.md) and [CONTRIBUTING](https://github.com/ilkilabs/ike-core/blob/core/docs/CONTRIBUTING.md) for more information.

## Community

Join IKE's community for discussion and ask questions : [IKE's Slack](http://slack.agorakube.ilkilabs.io/)

Channels :
- **#general** - For general purpose (news, events...)
- **#developpers** - For people who contribute to IKE by developing features
- **#end-users** - For end users who want to give us feedbacks
- **#random** - As its name suggests, for random discussions :)

## Licensing

All material here is released under the [APACHE 2.0 license](./LICENSE).
All material that is not executable, including all text when not executed,
is also released under the APACHE 2.0.
In SPDX terms, everything here is licensed under APACHE 2.0;
if it's not executable, including the text when extracted from code, it's
"(APACHE 2.0)".

Like almost all software today, this software depends on many
other components with their own licenses.
Not all components we depend on are APACHE 2.0-licensed, but all
*required* components are FLOSS. We prevent licensing issues
using various processes (see [CONTRIBUTING](./docs/CONTRIBUTING.md)).
