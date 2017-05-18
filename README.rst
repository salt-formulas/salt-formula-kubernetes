
==================
Kubernetes Formula
==================

Kubernetes is an open-source system for automating deployment, scaling, and management of containerized applications.

This formula deploys production ready Kubernetes and generate Kubernetes manifests as well.

Based on official Kubernetes salt
https://github.com/kubernetes/kubernetes/tree/master/cluster/saltbase

Extended on Contrail contribution https://github.com/Juniper/kubernetes/blob/opencontrail-integration/docs/getting-started-guides/opencontrail.md


Sample pillars
==============

**REQUIRED:** Define image to use for hyperkube, CNIs and calicoctl image

.. code-block:: yaml

    parameters:
      kubernetes:
        common:
          hyperkube:
            image: gcr.io/google_containers/hyperkube:v1.5.2
        pool:
          network:
            calicoctl:
              image: calico/ctl
            cni:
              image: calico/cni

Enable helm-tiller addon

.. code-block:: yaml

    parameters:
      kubernetes:
        master:
          addons:
            helm:
              enabled: true

Enable calico-policy addon

.. code-block:: yaml

    parameters:
      kubernetes:
        master:
          addons:
            calico_policy:
              enabled: true

Enable netchecker addon

.. code-block:: yaml

    parameters:
      kubernetes:
        master:
          namespace:
            netchecker:
              enabled: true
          addons:
            netchecker:
              enabled: true

Configure service verbosity

.. code-block:: yaml

    parameters:
      kubernetes:
        master:
          verbosity: 2
        pool:
          verbosity: 2

Enable autoscaler for dns addon. Poll period can be skipped.

.. code-block:: yaml

    kubernetes:
        master:
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
        master:
          addons:
            dns:
              domain: cluster.local
              enabled: true
              replicas: 1
              server: 10.254.0.10
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
            engine: calico
            hash: fb5e30ebe6154911a66ec3fb5f1195b2
            version: v0.19.0
          token:
            kube_proxy: DFvQ8GelB7afH3wClC9romaMPhquyyEe
            kubelet: 7bN5hJ9JD4fKjnFTkUKsvVNfuyEddw3r
          version: v1.2.4

Kubernetes with OpenContrail network plugin
------------------------------------------------

On Master:

.. code-block:: yaml

    kubernetes:
      master:
        network:
          engine: opencontrail
          host: 10.0.170.70
          port: 8082
          default_domain: default-domain
          default_project: default-domain:default-project
          public_network: default-domain:default-project:Public
          public_ip_range: 185.22.97.128/26
          private_ip_range: 10.150.0.0/16
          service_cluster_ip_range: 10.254.0.0/16
          network_label: name
          service_label: uses
          cluster_service: kube-system/default
          network_manager:
            image: pupapaik/opencontrail-kube-network-manager
            tag: release-1.1-jpa-final-1

On pools:

.. code-block:: yaml

    kubernetes:
      pool:
        network:
          engine: opencontrail

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

Kubernetes with Flannel
-----------------------

On Master:

.. code-block:: yaml

    kubernetes:
      master:
        network:
          engine: flannel
    # If you don't register master as node:
          etcd:
            members:
              - host: 10.0.175.101
                port: 4001
              - host: 10.0.175.102
                port: 4001
              - host: 10.0.175.103
                port: 4001
      common:
        network:
          engine: flannel

On pools:

.. code-block:: yaml

    kubernetes:
      pool:
        network:
          engine: flannel
          etcd:
            members:
              - host: 10.0.175.101
                port: 4001
              - host: 10.0.175.102
                port: 4001
              - host: 10.0.175.103
                port: 4001
      common:
        network:
          engine: flannel

Kubernetes with Calico
-----------------------

On Master:

.. code-block:: yaml

    kubernetes:
      master:
        network:
          engine: calico
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
          engine: calico
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
          engine: calico
          etcd:
            ssl:
              enabled: true
      master:
        network:
          engine: calico
          etcd:
            ssl:
              enabled: true

Running with calico-policy controller:

.. code-block:: yaml

    kubernetes:
      pool:
        network:
          engine: calico
          addons:
            calico_policy:
              enabled: true

      master:
        network:
          engine: calico
          addons:
            calico_policy:
              enabled: true



Enable Prometheus metrics in Felix

.. code-block:: yaml

    kubernetes:
      pool:
        network:
          prometheus:
            enabled: true
      master:
        network:
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

Documentation and Bugs
======================

To learn how to deploy OpenStack Salt, consult the documentation available
online at:

    https://wiki.openstack.org/wiki/OpenStackSalt

In the unfortunate event that bugs are discovered, they should be reported to
the appropriate bug tracker. If you obtained the software from a 3rd party
operating system vendor, it is often wise to use their own bug tracker for
reporting problems. In all other cases use the master OpenStack bug tracker,
available at:

    http://bugs.launchpad.net/openstack-salt

Developers wishing to work on the OpenStack Salt project should always base
their work on the latest formulas code, available from the master GIT
repository at:

    https://git.openstack.org/cgit/openstack/salt-formula-kubernetes

Developers should also join the discussion on the IRC list, at:

    https://wiki.openstack.org/wiki/Meetings/openstack-salt

Copyright and authors
=====================

(c) 2016 tcp cloud a.s.
(c) 2016 OpenStack Foundation

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
