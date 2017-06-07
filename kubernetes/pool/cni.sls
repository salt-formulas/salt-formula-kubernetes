{%- from "kubernetes/map.jinja" import pool with context %}
{%- from "kubernetes/map.jinja" import common with context %}
{%- if pool.enabled %}

{%- if common.hyperkube %}

/tmp/cni/:
  file.directory:
    - user: root
    - group: root
{%- if not grains.get('noservices', False) %}
copy-network-cni:
  dockerng.running:
    - image: {{ common.hyperkube.image }}
    - command: cp -vr /opt/cni/bin/ /tmp/cni/
    - binds:
      - /tmp/cni/:/tmp/cni/
    - force: True
    - require:
        - file: /tmp/cni/
{%- endif %}

{%- for filename in ['cnitool', 'flannel', 'tuning', 'bridge', 'ipvlan', 'loopback', 'macvlan', 'ptp', 'dhcp', 'host-local', 'noop'] %}
/opt/cni/bin/{{ filename }}:
  file.managed:
    - source: /tmp/cni/bin/{{ filename }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - watch_in:
      - service: kubelet_service
    {%- if not grains.get('noservices', False) %}
    - require:
      - dockerng: copy-network-cni
    {%- endif %}

{%- endfor %}

{%- endif %}

{%- endif %}
