kubernetes:
  common:
    cluster_domain: cluster.local
    cluster_name: cluster
    hyperkube:
      image: hyperkube-amd64:v1.6.4-3
      hash: hnsj0XqABgrSww7Nqo7UVTSZLJUt2XRd
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
      virtlet:
        enabled: true
        namespace: kube-system
        image: mirantis/virtlet:v1.0.3
    monitoring:
      backend: prometheus
  master:
    service_addresses: 127.0.0.1/24
    admin:
      password: password
      username: admin
    registry:
        host: tcpcloud
    host:
      name: node040
    apiserver:
      address: 10.0.175.100
      secure_port: 6443
      internal_address: 185.22.97.1
      insecure_address: 127.0.0.1
      insecure_port: 8080
    ca: kubernetes
    enabled: true
    unschedulable: true
    etcd:
      members:
      - host: 127.0.0.1
        name: node040
    kubelet:
      address: 10.0.175.100
      allow_privileged: true
    network:
      opencontrail:
        enabled: true
        version: 4.0
        private_ip_range: 10.150.0.0/16
        config:
          api:
            host: 127.0.0.1
        message_queue:
          host: 127.0.0.1
        identity:
          password: password
        database:
          members:
          - host: 127.0.0.1
          - host: 127.0.0.1
          - host: 127.0.0.1
        collector:
          members:
          - host: 127.0.0.1
          - host: 127.0.0.1
          - host: 127.0.0.1
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
