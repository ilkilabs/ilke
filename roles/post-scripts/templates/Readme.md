# Notes

## Nginx

We use official Ningix-controller yaml file.

We added **{{ ingress_nginx_release }}** variable to chose the correct nginx release to install.

This is useful when installing, and updateting Nginx with IKE

## Calico

Calico is configured in VxLAN-Cross-Subnet mode.

When updateing calico.yaml.j2, make sure that YAML file contains:

In **"calico-config"** ConfigMap:
* calico_backend: "vxlan"
* veth_mtu: "{{ calico_mtu }}"

In *"calico-node"* DaemonSet:
* Env CALICO_IPV4POOL_IPIP : "Never"
* Env: CALICO_IPV4POOL_VXLAN : "CrossSubnet"
* Env: CALICO_IPV4POOL_CIDR: "{{ cluster_cidr }}"
* Comment or delete : "-bird-live" and "-bird-ready" in livenessProbe and readynessProbe
