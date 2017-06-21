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
        enabled: false
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
        namespace: netchecker
        port: 80
        interval: 60
        server_image: image
        agent_image: image
        agent_probeurls: "http://ipinfo.io"
      calico_policy:
        enabled: true
        namespace: kube-system
        image: image
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
      etcd:
        members:
        - host: 127.0.0.1
          port: 4001
        - host: 127.0.0.1
          port: 4001
        - host: 127.0.0.1
          port: 4001
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
