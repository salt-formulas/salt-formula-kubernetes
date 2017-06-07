kubernetes:
  common:
    network:
      engine: none
    hyperkube:
      image: hyperkube-amd64:v1.5.0-beta.3-1
  master:
    addons:
      dns:
        domain: cluster.local
        enabled: true
        replicas: 1
        server: 10.254.0.10
        autoscaler:
          enabled: true
      heapster_influxdb:
        enabled: true
        public_ip: 185.22.97.132
      dashboard:
        enabled: true
        public_ip: 185.22.97.131
      helm:
        enabled: true
        tiller_image: gcr.io/kubernetes-helm/tiller:v2.2.3
      netchecker:
        enabled: true
        interval: 60
        namespace: netchecker
        port: 80
        agent_image: quay.io/l23network/k8s-netchecker-agent:v1.0
        server_image: quay.io/l23network/k8s-netchecker-server:v1.0
      calico_policy:
        enabled: true
        image: calico/kube-policy-controller:v0.5.4
        namespace: kube-system
    admin:
      password: password
      username: admin
    registry:
        host: tcpcloud
    host:
      name: node040
    apiserver:
      address: 10.0.175.100
      insecure_address: 127.0.0.1
      insecure_port: 8080
    ca: kubernetes
    enabled: true
    unschedulable: true
    etcd:
      members:
      - host: 10.0.175.100
        name: node040
    kubelet:
      allow_privileged: true
    network:
      engine: calico
      hash: fb5e30ebe6154911a66ec3fb5f1195b2
      private_ip_range: 10.150.0.0/16
      version: v0.19.0
    service_addresses: 10.254.0.0/16
    storage:
      engine: glusterfs
      members:
      - host: 10.0.175.101
        port: 24007
      - host: 10.0.175.102
        port: 24007
      - host: 10.0.175.103
        port: 24007
      port: 24007
    token:
      admin: DFvQ8GJ9JD4fKNfuyEddw3rjnFTkUKsv
      controller_manager: EreGh6AnWf8DxH8cYavB2zS029PUi7vx
      dns: RAFeVSE4UvsCz4gk3KYReuOI5jsZ1Xt3
      kube_proxy: DFvQ8GelB7afH3wClC9romaMPhquyyEe
      kubelet: 7bN5hJ9JD4fKjnFTkUKsvVNfuyEddw3r
      logging: MJkXKdbgqRmTHSa2ykTaOaMykgO6KcEf
      monitoring: hnsj0XqABgrSww7Nqo7UVTSZLJUt2XRd
      scheduler: HY1UUxEPpmjW4a1dDLGIANYQp1nZkLDk
    version: v1.2.4
    namespace:
      kube-system:
        enabled: true
      netchecker:
        enabled: true
    hyperkube:
      hash: hnsj0XqABgrSww7Nqo7UVTSZLJUt2XRd
    services:
      myservice:
        enabled: true
        files:
          - /srv/kubernetes/myservice-svc.yml
          - /srv/kubernetes/myservice-pvc.yml
          - /srv/kubernetes/myservice-deploy.yml
  pool:
    enabled: true
    version: v1.2.0
    host:
      name: ${linux:system:name}
    apiserver:
      host: 127.0.0.1
      insecure:
        enabled: True
      members:
        - host: 127.0.0.1
        - host: 127.0.0.1
        - host: 127.0.0.1
    address: 0.0.0.0
    cluster_dns: 10.254.0.10
    cluster_domain: cluster.local
    kubelet:
      config: /etc/kubernetes/manifests
      allow_privileged: True
      frequency: 5s
    token:
      kubelet: 7bN5hJ9JD4fKjnFTkUKsvVNfuyEddw3r
      kube_proxy: DFvQ8GelB7afH3wClC9romaMPhquyyEe
    ca: kubernetes
    network:
      calicoctl:
        image: calico/ctl
      cni:
        image: calico/cni
      engine: calico
      hash: c15ae251b633109e63bf128c2fbbc34a
      ipam:
        hash: 6e6d7fac0567a8d90a334dcbfd019a99
        version: v1.3.1
      version: v0.20.0
      etcd:
        members:
        - host: 127.0.0.1
          port: 4001
        - host: 127.0.0.1
          port: 4001
        - host: 127.0.0.1
          port: 4001
    hyperkube:
      hash: hnsj0XqABgrSww7Nqo7UVTSZLJUt2XRd