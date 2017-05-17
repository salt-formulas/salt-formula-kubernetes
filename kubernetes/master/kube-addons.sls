{%- from "kubernetes/map.jinja" import master with context %}
{%- if master.enabled %}

addon-dir-create:
  file.directory:
    - name: /etc/kubernetes/addons
    - user: root
    - group: root
    - mode: 0755

{%- if master.addons.calico_policy.enabled and master.network.engine == "calico" %}
/etc/kubernetes/addons/calico-policy/calico-policy-controller.yml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/calico-policy/calico-policy-controller.yml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{% endif %}


{%- if master.addons.helm.enabled %}
/etc/kubernetes/addons/helm/helm-tiller-deploy.yml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/helm/helm-tiller-deploy.yml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{% endif %}

{%- if master.addons.netchecker.enabled %}

{%- for resource in ['svc', 'server', 'agent'] %}

/etc/kubernetes/addons/netchecker/netchecker-{{ resource }}.yml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/netchecker/netchecker-{{ resource }}.yml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{%- endfor %}

{% endif %}


{%- if master.addons.dns.enabled %}

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

{% if master.addons.dns.get('autoscaler', {}).get('enabled', True) %}

/etc/kubernetes/addons/dns/kubedns-autoscaler.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/dns/kubedns-autoscaler.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{% endif %}

{% endif %}

{%- if master.addons.dashboard.enabled %}

/etc/kubernetes/addons/dashboard/dashboard-service.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/dashboard/dashboard-service.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

/etc/kubernetes/addons/dashboard/dashboard-controller.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/dashboard/dashboard-controller.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{%- if master.network.engine == "opencontrail" %}

/etc/kubernetes/addons/dashboard/dashboard-address.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/dashboard/dashboard-address.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

/etc/kubernetes/addons/dashboard/dashboard-endpoint.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/dashboard/dashboard-endpoint.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True
{% endif %}

{% endif %}

{%- if master.addons.heapster_influxdb.enabled %}

/etc/kubernetes/addons/heapster-influxdb/heapster-address.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/heapster-influxdb/heapster-address.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

/etc/kubernetes/addons/heapster-influxdb/heapster-controller.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/heapster-influxdb/heapster-controller.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

/etc/kubernetes/addons/heapster-influxdb/heapster-endpoint.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/heapster-influxdb/heapster-endpoint.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

/etc/kubernetes/addons/heapster-influxdb/heapster-service.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/heapster-influxdb/heapster-service.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

/etc/kubernetes/addons/heapster-influxdb/influxdb-controller.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/heapster-influxdb/influxdb-controller.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

/etc/kubernetes/addons/heapster-influxdb/influxdb-service.yaml:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/heapster-influxdb/influxdb-service.yaml
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

{% endif %}

{% endif %}
