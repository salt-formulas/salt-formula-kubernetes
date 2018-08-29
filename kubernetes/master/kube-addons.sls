{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}
{%- if master.enabled %}

addon-dir-create:
  file.directory:
    - name: /etc/kubernetes/addons
    - user: root
    - group: root
    - mode: 0755

{%- if common.addons.get('metallb', {}).get('enabled', False) %}
/etc/kubernetes/addons/metallb/metallb.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/metallb/metallb.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True
{% endif %}

{%- if master.network.get('flannel', {}).get('enabled', False) %}
/etc/kubernetes/addons/flannel/flannel.yml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/flannel/flannel.yml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True
{% endif %}

{%- if master.network.get('opencontrail', {}).get('enabled', False) and master.network.opencontrail.get('version', 3.0) < 4.0 %}
/etc/kubernetes/addons/contrail-network-controller/contrail-network-controller-configmap.yml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/contrail-network-controller/contrail-network-controller-configmap.yml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

/etc/kubernetes/addons/contrail-network-controller/contrail-network-controller-deploy.yml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/contrail-network-controller/contrail-network-controller-deploy.yml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{%- elif master.network.get('opencontrail', {}).get('enabled', False) and master.network.opencontrail.get('version', 3.0) > 3.0 %}

/etc/kubernetes/addons/contrail/contrail.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/contrail/contrail.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

/etc/kubernetes/addons/contrail/kube-manager.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/contrail/kube-manager.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{% endif %}

{%- if common.addons.get('virtlet', {}).get('enabled') %}
/etc/kubernetes/addons/virtlet/virtlet-ds.yml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/virtlet/virtlet-ds.yml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{% endif %}

{%- if master.network.get('calico', {}).get('enabled', False) %}
/etc/kubernetes/addons/calico/calico-kube-controllers.yml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/calico/calico-kube-controllers.yml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

/etc/kubernetes/addons/calico/calico-rbac.yml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/calico/calico-rbac.yml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{% endif %}


{%- if common.addons.get('helm', {'enabled': False}).enabled %}
/etc/kubernetes/addons/helm/helm-tiller-deploy.yml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/helm/helm-tiller-deploy.yml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{%- if 'RBAC' in master.auth.get('mode', "") %}

/etc/kubernetes/addons/helm/helm-role.yml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/helm/helm-role.yml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

/etc/kubernetes/addons/helm/helm-serviceaccount.yml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/helm/helm-serviceaccount.yml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{%- endif %}

{% endif %}

{%- if common.addons.storageclass is defined %}

{%- for storageclass_name, storageclass in common.addons.get('storageclass', {}).items() %}
{%- set storageclass_name = storageclass.get('name', storageclass_name) %}

/etc/kubernetes/addons/storageclass/{{ storageclass_name }}.yaml:
  file.managed:
  - source: salt://kubernetes/files/kube-addons/storageclass/{{ storageclass.provisioner }}.yaml
  - template: jinja
  - makedirs: True
  - dir_mode: 755
  - group: root
  - defaults:
      storageclass_name: {{ storageclass_name }}
      storageclass: {{ storageclass|yaml }}

{%- endfor %}

{% endif %}

{%- if common.addons.get('netchecker', {'enabled': False}).enabled %}

{%- set netchecker_resources = ['svc', 'server', 'agent', 'serviceaccount'] %}

{%- if 'RBAC' in master.auth.get('mode', "") %}

{%- set netchecker_resources = netchecker_resources + ['roles'] %}

{%- endif %}

{%- for resource in netchecker_resources %}

/etc/kubernetes/addons/netchecker/netchecker-{{ resource }}.yml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/netchecker/netchecker-{{ resource }}.yml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{%- endfor %}

{% endif %}

{%- if common.monitoring.get('backend', "") == 'prometheus' %}

{%- if 'RBAC' in master.auth.get('mode', "") %}

/etc/kubernetes/addons/prometheus/prometheus-roles.yml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/prometheus/prometheus-roles.yml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{%- endif %}

{%- endif %}

{%- if common.addons.get('dns', {'enabled': False}).enabled %}

/etc/kubernetes/addons/dns/kubedns-svc.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/dns/kubedns-svc.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

/etc/kubernetes/addons/dns/kubedns-rc.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/dns/kubedns-rc.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

/etc/kubernetes/addons/dns/kubedns-sa.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/dns/kubedns-sa.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{% if common.addons.dns.get('autoscaler', {}).get('enabled', True) %}

/etc/kubernetes/addons/dns/kubedns-autoscaler.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/dns/kubedns-autoscaler.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{%- if 'RBAC' in master.auth.get('mode', "") %}

/etc/kubernetes/addons/dns/kubedns-autoscaler-rbac.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/dns/kubedns-autoscaler-rbac.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

/etc/kubernetes/addons/dns/kubedns-clusterrole.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/dns/kubedns-clusterrole.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{% endif %}

{% endif %}

{%- if common.addons.coredns.enabled or master.federation.enabled %}
/etc/kubernetes/addons/coredns/coredns-etcd-operator-deployment.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/coredns/coredns-etcd-operator-deployment.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

/etc/kubernetes/addons/coredns/coredns-etcd-cluster.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/coredns/coredns-etcd-cluster.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

/etc/kubernetes/addons/coredns/coredns-cm.yml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/coredns/coredns-cm.yml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

/etc/kubernetes/addons/coredns/coredns-deploy.yml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/coredns/coredns-deploy.yml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

/etc/kubernetes/addons/coredns/coredns-svc.yml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/coredns/coredns-svc.yml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True
{% endif %}

{% endif %}

{%- if common.addons.get('externaldns', {}).get('enabled') %}
/etc/kubernetes/addons/externaldns/externaldns-deploy.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/externaldns/externaldns-deploy.yml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{%- if common.addons.get('externaldns', {}).get('provider') == 'designate' %}
/etc/kubernetes/addons/externaldns/externaldns-designate-secret.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/externaldns/externaldns-designate-secret.yaml
    - template: jinja
    - group: root
{% endif %}

{%- if common.addons.get('externaldns', {}).get('provider') == 'aws' %}
/etc/kubernetes/addons/externaldns/externaldns-aws-secret.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/externaldns/externaldns-aws-secret.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True
{% endif %}

{%- if common.addons.get('externaldns', {}).get('provider') == 'google' %}
/etc/kubernetes/addons/externaldns/externaldns-google-secret.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/externaldns/externaldns-google-secret.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True
{% endif %}

{% endif %}

{%- if common.addons.get('fluentd', {}).get('enabled') %}

/etc/kubernetes/addons/fluentd/fluentd-ns.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/fluentd/fluentd-ns.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

/etc/kubernetes/addons/fluentd/fluentd-sa.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/fluentd/fluentd-sa.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{%- set fluentd_aggregator_resources = ['fluent-conf','deploy', 'svc'] %}
{%- for resource in fluentd_aggregator_resources %}

/etc/kubernetes/addons/fluentd/fluentd-aggregator-{{ resource }}.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/fluentd/fluentd-aggregator-{{ resource }}.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{%- endfor %}

{%- set fluentd_logger_resources = ['fluent-conf', 'ds'] %}
{%- for resource in fluentd_logger_resources %}

/etc/kubernetes/addons/fluentd/fluentd-logger-{{ resource }}.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/fluentd/fluentd-logger-{{ resource }}.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{%- endfor %}

{% endif %}

{%- if common.addons.get('telegraf', {}).get('enabled') %}
{%- set telegraf_resources = ['conf', 'ns', 'sa', 'ds'] %}

{%- for resource in telegraf_resources %}
/etc/kubernetes/addons/telegraf/telegraf-{{ resource }}.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/telegraf/telegraf-{{ resource }}.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True
{%- endfor %}

{% endif %}

{%- if common.addons.get('dashboard', {'enabled': False}).enabled %}

{%- set dashboard_resources = ['deployment', 'secret', 'service', 'serviceaccount'] %}

{%- if 'RBAC' in master.auth.get('mode', "") %}

{%- set dashboard_resources = dashboard_resources + ['role', 'rolebinding'] %}

{%- endif %}

{%- for resource in dashboard_resources %}

/etc/kubernetes/addons/dashboard/dashboard-{{ resource }}.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/dashboard/dashboard-{{ resource }}.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{%- endfor %}

{% endif %}

{%- if common.addons.get('heapster_influxdb', {'enabled': False}).enabled %}

{%- set heapster_resources = ['address', 'controller', 'endpoint', 'service'] %}

{%- if 'RBAC' in master.auth.get('mode', "") %}

{%- set heapster_resources = heapster_resources + ['account', 'role'] %}

{%- endif %}

{%- for resource in heapster_resources %}

/etc/kubernetes/addons/heapster-influxdb/heapster-{{ resource }}.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/heapster-influxdb/heapster-{{ resource }}.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{%- endfor %}

{%- set influxdb_resources = ['controller', 'service'] %}

{%- for resource in influxdb_resources %}

/etc/kubernetes/addons/heapster-influxdb/influxdb-{{ resource }}.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/heapster-influxdb/influxdb-{{ resource }}.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{%- endfor %}

{% endif %}

{% endif %}
