==================
Kubernetes Formula
==================

Kubernetes is an open-source system for automating deployment, scaling, and
management of containerized applications. This formula deploys production
ready Kubernetes and generate Kubernetes manifests as well.

You can download `kubectl` configuration and connect to your cluster. However,
keep in mind `kubernetes_control_address` needs to be accessible from your computer:

.. code-block:: yaml

  mkdir -p ~/.kube
  [ -f ~/.kube/config ] && cp -v ~/.kube/config ~/.kube/config-backup
  ssh cfg01 "sudo ssh ctl01 /etc/kubernetes/kubeconfig.sh" > ~/.kube/config
  kubectl get no


`cfg01` is Salt master node and `ctl01` is one of Kubernetes masters

Sample Pillars
==============

**REQUIRED:** Define images to use for hyperkube and Calico

.. code-block:: yaml

    parameters:
      kubernetes:
        common:
          hyperkube:
            image: gcr.io/google_containers/hyperkube:v1.6.5
        pool:
          network:
            calico:
              calicoctl_image: calico/ctl
              cni_image: calico/cni
              image: calico/node
              kube_controllers_image: calico/kube-controllers


Enable helm-tiller addon

.. code-block:: yaml

    parameters:
      kubernetes:
        common:
          addons:
            helm:
              enabled: true

Enable calico-policy

.. code-block:: yaml

    parameters:
      kubernetes:
        pool:
          network:
            calico:
              policy:
                enabled: true

Enable virtlet addon

.. code-block:: yaml

    parameters:
      kubernetes:
        common:
          addons:
            virtlet:
              enabled: true
              namespace: kube-system
              image: mirantis/virtlet:v1.0.3

Enable netchecker addon

.. code-block:: yaml

    parameters:
      kubernetes:
        common:
          addons:
            netchecker:
              enabled: true
        master:
          namespace:
            netchecker:
              enabled: true

Enable Kubenetes Federation control plane

.. code-block:: yaml

    parameters:
      kubernetes:
        master:
          federation:
            enabled: True
            name: federation
            namespace: federation-system
            source: https://dl.k8s.io/v1.6.6/kubernetes-client-linux-amd64.tar.gz
            hash: 94b2c9cd29981a8e150c187193bab0d8c0b6e906260f837367feff99860a6376
            service_type: NodePort
            dns_provider: coredns
            childclusters:
              - secondcluster.mydomain
              - thirdcluster.mydomain

Enable external DNS addon with CoreDNS provider

.. code-block:: yaml

    parameters:
      kubernetes:
        common:
          addons:
            coredns:
              enabled: True
            externaldns:
              enabled: True
              domain: company.mydomain
              provider: coredns

Enable external DNS addon with Designate provider

.. code-block:: yaml

    parameters:
      kubernetes:
        common:
          addons:
            externaldns:
              enabled: True
              domain: company.mydomain
              provider: designate
              designate_os_options:
                OS_AUTH_URL: https://keystone_auth_endpoint:5000
                OS_PROJECT_DOMAIN_NAME: default
                OS_USER_DOMAIN_NAME: default
                OS_PROJECT_NAME: admin
                OS_USERNAME: admin
                OS_PASSWORD: password
                OS_REGION_NAME: RegionOne

Enable external DNS addon with AWS provider

.. code-block:: yaml

    parameters:
      kubernetes:
        common:
          addons:
            externaldns:
              enabled: True
              domain: company.mydomain
              provider: aws
              aws_options:
                AWS_ACCESS_KEY_ID: XXXXXXXXXXXXXXXXXXXX
                AWS_SECRET_ACCESS_KEY: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

Enable external DNS addon with Google CloudDNS provider

.. code-block:: yaml

    parameters:
      kubernetes:
        common:
          addons:
            externaldns:
              enabled: True
              domain: company.mydomain
              provider: google
              google_options:
                key: ''
                project: default-123
key should be exported from google console and processed as `cat key.json | tr -d '\n'`

Enable OpenStack cloud provider

.. code-block:: yaml

    parameters:
      kubernetes:
        common:
          cloudprovider:
            enabled: True
            provider: openstack
            params:
              auth_url: https://openstack.mydomain:5000/v3
              username: nova
              password: nova
              region: RegionOne
              tenant_id: 4bce4162d8744c599e350099cfa22a0a
              domain_name: default
              subnet_id: 72407854-aca6-4cf1-b873-e9affb09484b
              lb_version: v2

Configure service verbosity

.. code-block:: yaml

    parameters:
      kubernetes:
        master:
          verbosity: 2
        pool:
          verbosity: 2

Set cluster name and domain

.. code-block:: yaml

    parameters:
      kubernetes:
        common:
          kubernetes_cluster_domain: mycluster.domain
          cluster_name : mycluster

Enable autoscaler for dns addon. Poll period can be skipped.

.. code-block:: yaml

    kubernetes:
        common:
          addons:
            dns:
              domain: cluster.local
              enabled: true
              replicas: 1
              server: 10.254.0.10
              autoscaler:
                enabled: true
                poll-period-seconds: 60


Pass aditional parameters to daemons:

.. code-block:: yaml

    parameters:
      kubernetes:
        master:
          apiserver:
            daemon_opts:
              storage-backend: pigeon
          controller_manager:
            daemon_opts:
              log-dir: /dev/nulL
        pool:
          kubelet:
            daemon_opts:
              max-pods: "6"


Containers on pool definitions in pool.service.local

.. code-block:: yaml

    parameters:
      kubernetes:
        pool:
          service:
            local:
              enabled: False
              service: libvirt
              cluster: openstack-compute
              namespace: default
              role: ${linux:system:name}
              type: LoadBalancer
              kind: Deployment
              apiVersion: extensions/v1beta1
              replicas: 1
              host_pid: True
              nodeSelector:
              - key: openstack
                value: ${linux:system:name}
              hostNetwork: True
              container:
                libvirt-compute:
                  privileged: True
                  image: ${_param:docker_repository}/libvirt-compute
                  tag: ${_param:openstack_container_tag}

Master definition

.. code-block:: yaml

    kubernetes:
        common:
          cluster_name: cluster
          addons:
            dns:
              domain: cluster.local
              enabled: true
              replicas: 1
              server: 10.254.0.10
        master:
          admin:
            password: password
            username: admin
          apiserver:
            address: 10.0.175.100
            secure_port: 443
            insecure_address: 127.0.0.1
            insecure_port: 8080
          ca: kubernetes
          enabled: true
          etcd:
            host: 127.0.0.1
            members:
            - host: 10.0.175.100
              name: node040
            name: node040
            token: ca939ec9c2a17b0786f6d411fe019e9b
          kubelet:
            allow_privileged: true
          network:
            calico:
              enabled: true
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


    kubernetes:
        pool:
          address: 0.0.0.0
          allow_privileged: true
          ca: kubernetes
          cluster_dns: 10.254.0.10
          cluster_domain: cluster.local
          enabled: true
          kubelet:
            allow_privileged: true
            config: /etc/kubernetes/manifests
            frequency: 5s
          master:
            apiserver:
              members:
              - host: 10.0.175.100
            etcd:
              members:
              - host: 10.0.175.100
            host: 10.0.175.100
          network:
            calico:
              enabled: true
          token:
            kube_proxy: DFvQ8GelB7afH3wClC9romaMPhquyyEe
            kubelet: 7bN5hJ9JD4fKjnFTkUKsvVNfuyEddw3r
          version: v1.2.4


Enable basic, token and http authentication, disable ssl auth, create some
static users:

.. code-block:: yaml

    kubernetes:
      master:
        auth:
          basic:
            enabled: true
            user:
              jdoe:
                password: dummy
                groups:
                  - system:admin
          http:
            enabled: true
            header:
              user: X-Remote-User
              group: X-Remote-Group
          ssl:
            enabled: false
          token:
            enabled: true
            user:
              jdoe:
                token: dummytoken
                groups:
                  - system:admin

Kubernetes with OpenContrail network plugin
------------------------------------------------

On Master:

.. code-block:: yaml

    kubernetes:
      common:
        addons:
          contrail_network_controller:
            enabled: true
            namespace: kube-system
            image: yashulyak/contrail-controller:latest
      master:
        network:
          opencontrail:
            enabled: true
            default_domain: default-domain
            default_project: default-domain:default-project
            public_network: default-domain:default-project:Public
            public_ip_range: 185.22.97.128/26
            private_ip_range: 10.150.0.0/16
            service_cluster_ip_range: 10.254.0.0/16
            network_label: name
            service_label: uses
            cluster_service: kube-system/default
            config:
              api:
                host: 10.0.170.70
On pools:

.. code-block:: yaml

    kubernetes:
      pool:
        network:
          opencontrail:
            enabled: true


Dashboard public IP must be configured when Contrail network is used:

.. code-block:: yaml

    kubernetes:
      common:
        addons:
          dashboard:
            public_ip: 1.1.1.1

Kubernetes control plane running in systemd
-------------------------------------------

By default kube-apiserver, kube-scheduler, kube-controllermanager, kube-proxy, etcd running in docker containers through manifests. For stable production environment this should be run in systemd.

.. code-block:: yaml

    kubernetes:
      master:
        container: false

    kubernetes:
      pool:
        container: false

Because k8s services run under kube user without root privileges, there is need to change secure port for apiserver.

.. code-block:: yaml

    kubernetes:
      master:
        apiserver:
          secure_port: 8081

Kubernetes with MetalLB
-----------------------

On Master:

.. code-block:: yaml

    kubernetes:
      common:
        addons:
          metallb:
            enabled: true
            addresses:
            - 172.16.10.150-172.16.10.180
            - 172.16.10.192/26

Kubernetes with SRIOV
-----------------------

On Master:

.. code-block:: yaml

    kubernetes:
      master:
        network:
          sriov:
            enabled: true
            interface: eno2
            subnet: 10.55.208.0/24
            gateway: 10.55.208.1

On pools:

.. code-block:: yaml

    kubernetes:
      pool:
        network:
          sriov:
            enabled: true
            interface: eno2
            subnet: 10.55.208.0/24
            gateway: 10.55.208.1

Kubernetes with Flannel
-----------------------

On Master:

.. code-block:: yaml

    kubernetes:
      master:
        network:
          flannel:
            enabled: true

On pools:

.. code-block:: yaml

    kubernetes:
      pool:
        network:
          flannel:
            enabled: true

Kubernetes with Calico
-----------------------

On Master:

.. code-block:: yaml

    kubernetes:
      master:
        network:
          calico:
            enabled: true
            mtu: 1500
    # If you don't register master as node:
            etcd:
              members:
                - host: 10.0.175.101
                  port: 4001
                - host: 10.0.175.102
                  port: 4001
                - host: 10.0.175.103
                  port: 4001

On pools:

.. code-block:: yaml

    kubernetes:
      pool:
        network:
          calico:
            enabled: true
            mtu: 1500
            etcd:
              members:
                - host: 10.0.175.101
                  port: 4001
                - host: 10.0.175.102
                  port: 4001
                - host: 10.0.175.103
                  port: 4001

Running with secured etcd:

.. code-block:: yaml

    kubernetes:
      pool:
        network:
          calico:
            enabled: true
            etcd:
              ssl:
                enabled: true
      master:
        network:
          calico:
            enabled: true
            etcd:
              ssl:
                enabled: true

Running with calico-policy:

.. code-block:: yaml

    kubernetes:
      pool:
        network:
          calico:
            enabled: true
            policy:
              enabled: true

      master:
        network:
          calico:
            enabled: true
            policy:
              enabled: true



Enable Prometheus metrics in Felix

.. code-block:: yaml

    kubernetes:
      pool:
        network:
          calico:
            prometheus:
              enabled: true
      master:
        network:
          calico:
            prometheus:
              enabled: true

Post deployment configuration

.. code-block:: bash

    # set ETCD
    export ETCD_AUTHORITY=10.0.111.201:4001

    # Set NAT for pods subnet
    calicoctl pool add 192.168.0.0/16 --nat-outgoing

    # Status commands
    calicoctl status
    calicoctl node show

Kubernetes with GlusterFS for storage
---------------------------------------------

.. code-block:: yaml

    kubernetes:
      master:
        ...
        storage:
          engine: glusterfs
          port: 24007
          members:
          - host: 10.0.175.101
            port: 24007
          - host: 10.0.175.102
            port: 24007
          - host: 10.0.175.103
            port: 24007
         ...

Kubernetes Storage Class
------------------------

AWS EBS storageclass integration. It also requires to create IAM policy and profiles for instances and tag all resources by KubernetesCluster in EC2.

.. code-block:: yaml

    kubernetes:
      common:
        addons:
          storageclass:
            aws_slow:
              enabled: True
              default: True
              provisioner: aws-ebs
              name: slow
              type: gp2
              iopspergb: "10"
              zones: xxx
            nfs_shared:
              name: elasti01
              enabled: True
              provisioner: nfs
              spec:
                name: elastic_data
                nfs:
                  server: 10.0.0.1
                  path: /exported_path

Kubernetes namespaces
---------------------

Create namespace:

.. code-block:: yaml

    kubernetes:
      master:
        ...
        namespace:
          kube-system:
            enabled: True
          namespace2:
            enabled: True
          namespace3:
            enabled: False
         ...

Kubernetes labels
-----------------

Label node:

.. code-block:: yaml

  kubernetes:
    master:
      label:
        label01:
          value: value01
          node: node01
          enabled: true
          key: key01
        ...

Pull images from private registries
-----------------------------------

.. code-block:: yaml

    kubernetes:
      master:
        ...
        registry:
          secret:
            registry01:
              enabled: True
              key: (get from `cat /root/.docker/config.json | base64`)
              namespace: default
         ...
      control:
        ...
        service:
          service01:
          ...
          image_pull_secretes: registry01
          ...

Kubernetes Service Definitions in pillars
==========================================

Following samples show how to generate kubernetes manifest as well and provide single tool for complete infrastructure management.

Deployment manifest
---------------------

.. code-block:: yaml

  salt:
    control:
      enabled: True
      hostNetwork: True
      service:
        memcached:
          privileged: True
          service: memcached
          role: server
          type: LoadBalancer
          replicas: 3
          kind: Deployment
          apiVersion: extensions/v1beta1
          ports:
          - port: 8774
            name: nova-api
          - port: 8775
            name: nova-metadata
          volume:
            volume_name:
              type: hostPath
              mount: /certs
              path: /etc/certs
          container:
            memcached:
              image: memcached
              tag:2
              ports:
              - port: 8774
                name: nova-api
              - port: 8775
                name: nova-metadata
              variables:
              - name: HTTP_TLS_CERTIFICATE:
                value: /certs/domain.crt
              - name: HTTP_TLS_KEY
                value: /certs/domain.key
              volumes:
              - name: /etc/certs
                type: hostPath
                mount: /certs
                path: /etc/certs

PetSet manifest
---------------------

.. code-block:: yaml

  service:
    memcached:
      apiVersion: apps/v1alpha1
      kind: PetSet
      service_name: 'memcached'
      container:
        memcached:
      ...


Configmap
---------

You are able to create configmaps using support layer between formulas.
It works simple, eg. in nova formula there's file ``meta/config.yml`` which
defines config files used by that service and roles.

Kubernetes formula is able to generate these files using custom pillar and
grains structure. This way you are able to run docker images built by any way
while still re-using your configuration management.

Example pillar:

.. code-block:: bash

    kubernetes:
      control:
        config_type: default|kubernetes # Output is yaml k8s or default single files
        configmap:
          nova-control:
            grains:
              # Alternate grains as OS running in container may differ from
              # salt minion OS. Needed only if grains matters for config
              # generation.
              os_family: Debian
            pillar:
              # Generic pillar for nova controller
              nova:
                controller:
                  enabled: true
                  versionn: liberty
                  ...

To tell which services supports config generation, you need to ensure pillar
structure like this to determine support:

.. code-block:: yaml

    nova:
      _support:
        config:
          enabled: true

initContainers
--------------

Example pillar:

.. code-block:: bash

    kubernetes:
      control:
      service:
        memcached:
          init_containers:
          - name: test-mysql
            image: busybox
            command:
            - sleep
            - 3600
            volumes:
            - name: config
              mount: /test
          - name: test-memcached
            image: busybox
            command:
            - sleep
            - 3600
            volumes:
            - name: config
              mount: /test

Affinity
--------

podAffinity
===========

Example pillar:

.. code-block:: bash

    kubernetes:
      control:
      service:
        memcached:
          affinity:
            pod_affinity:
              name: podAffinity
              expression:
                label_selector:
                  name: labelSelector
                  selectors:
                  - key: app
                    value: memcached
              topology_key: kubernetes.io/hostname

podAntiAffinity
===============

Example pillar:

.. code-block:: bash

    kubernetes:
      control:
      service:
        memcached:
          affinity:
            anti_affinity:
              name: podAntiAffinity
              expression:
                label_selector:
                  name: labelSelector
                  selectors:
                  - key: app
                    value: opencontrail-control
              topology_key: kubernetes.io/hostname

nodeAffinity
===============

Example pillar:

.. code-block:: bash

    kubernetes:
      control:
      service:
        memcached:
          affinity:
            node_affinity:
              name: nodeAffinity
              expression:
                match_expressions:
                  name: matchExpressions
                  selectors:
                  - key: key
                    operator: In
                    values:
                    - value1
                    - value2

Volumes
-------

hostPath
==========

.. code-block:: yaml

  service:
    memcached:
      container:
        memcached:
          volumes:
            - name: volume1
              mountPath: /volume
              readOnly: True
      ...
      volume:
        volume1:
          name: /etc/certs
          type: hostPath
          path: /etc/certs

emptyDir
========

.. code-block:: yaml

  service:
    memcached:
      container:
        memcached:
          volumes:
            - name: volume1
              mountPath: /volume
              readOnly: True
      ...
      volume:
        volume1:
          name: /etc/certs
          type: emptyDir

configMap
=========

.. code-block:: yaml

  service:
    memcached:
      container:
        memcached:
          volumes:
            - name: volume1
              mountPath: /volume
              readOnly: True
      ...
      volume:
        volume1:
          type: config_map
          item:
            configMap1:
              key: config.conf
              path: config.conf
            configMap2:
              key: policy.json
              path: policy.json

To mount single configuration file instead of whole directory:

.. code-block:: yaml

  service:
    memcached:
      container:
        memcached:
          volumes:
            - name: volume1
              mountPath: /volume/config.conf
              sub_path: config.conf

Generating Jobs
===============

Example pillar:

.. code-block:: yaml

  kubernetes:
    control:
      job:
        sleep:
          job: sleep
          restart_policy: Never
          container:
            sleep:
              image: busybox
              tag: latest
              command:
              - sleep
              - "3600"

Volumes and Variables can be used as the same way as during Deployment generation.

Custom params:

.. code-block:: yaml

  kubernetes:
    control:
      job:
        host_network: True
        host_pid: True
        container:
          sleep:
            privileged: True
        node_selector:
          key: node
          value: one
        image_pull_secretes: password

Role-based access control
=========================

To enable RBAC, you need to set following option on your apiserver:

.. code-block:: yaml

    kubernetes:
      master:
        auth:
          mode: Node,RBAC

Then you can use ``kubernetes.control.role`` state to orchestrate role and
rolebindings. Following example shows how to create brand new role and binding
for service account:

.. code-block:: yaml

    control:
      role:
        etcd-operator:
          kind: ClusterRole
          rules:
            - apiGroups:
                - etcd.coreos.com
              resources:
                - clusters
              verbs:
                - "*"
            - apiGroups:
                - extensions
              resources:
                - thirdpartyresources
              verbs:
                - create
            - apiGroups:
                - storage.k8s.io
              resources:
                - storageclasses
              verbs:
                - create
            - apiGroups:
                - ""
              resources:
                - replicasets
              verbs:
                - "*"
          binding:
            etcd-operator:
              kind: ClusterRoleBinding
              namespace: test # <-- if no namespace, then it's clusterrolebinding
              subject:
                etcd-operator:
                  kind: ServiceAccount

Simplest possible use-case, add user test edit permissions on it's test
namespace:

.. code-block:: yaml

    kubernetes:
      control:
        role:
          edit:
            kind: ClusterRole
            # No rules defined, so only binding will be created assuming role
            # already exists
            binding:
              test:
                namespace: test
                subject:
                  test:
                    kind: User

More Information
================

* https://github.com/Juniper/kubernetes/blob
/opencontrail-integration/docs /getting-started-guides/opencontrail.md
* https://github.com/kubernetes/kubernetes/tree/master/cluster/saltbase


Documentation and Bugs
======================

To learn how to install and update salt-formulas, consult the documentation
available online at:

    http://salt-formulas.readthedocs.io/

In the unfortunate event that bugs are discovered, they should be reported to
the appropriate issue tracker. Use Github issue tracker for specific salt
formula:

    https://github.com/salt-formulas/salt-formula-kubernetes/issues

For feature requests, bug reports or blueprints affecting entire ecosystem,
use Launchpad salt-formulas project:

    https://launchpad.net/salt-formulas

You can also join salt-formulas-users team and subscribe to mailing list:

    https://launchpad.net/~salt-formulas-users

Developers wishing to work on the salt-formulas projects should always base
their work on master branch and submit pull request against specific formula.

    https://github.com/salt-formulas/salt-formula-kubernetes

Any questions or feedback is always welcome so feel free to join our IRC
channel:

    #salt-formulas @ irc.freenode.net
