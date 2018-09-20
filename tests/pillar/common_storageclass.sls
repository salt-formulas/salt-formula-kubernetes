kubernetes:
  master:
    enabled: true
    admin:
      password: password
      username: admin
    apiserver:
      address: 10.0.175.100
      secure_port: 6443
      internal_address: 182.22.97.1
      insecure_address: 127.0.0.1
      insecure_port: 8080
    version: v1.2.4
    host:
      name: node040
    etcd:
      members:
      - host: 10.0.175.100
        name: node040
    namespace:
      kube-system:
        enabled: true
    network:
      calico:
        enabled: true
        calicoctl_image: calico/ctl
        cni_image: calico/cni
        image: calico/node
        kube_controllers_image: calico/kube-controllers
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
    registry:
        host: tcpcloud
  common:
    addons:
      storageclass:
        nfs_elastic_1:
          enabled: True
          provisioner: nfs
          spec:
            name: elastic_data
            nfs:
              server: 10.0.0.1
              path: /exported_path/elastic01
        nfs_elastic_2:
          enabled: True
          provisioner: nfs
          spec:
            name: elastic_data
            nfs:
              server: 10.0.0.1
              path: /exported_path/elastic02
        nfs_influx:
          name: influx01
          enabled: False
          provisioner: nfs
          spec:
            name: influx
            nfs:
              server: 10.0.0.1
              path: /exported_path/inlfux01
    monitoring:
      backend: prometheus
