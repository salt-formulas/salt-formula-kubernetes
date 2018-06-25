{%- from "kubernetes/map.jinja" import pool with context %}
{%- if pool.enabled %}

/etc/cni/net.d/13-sriov.conf:
  file.managed:
    - source: salt://kubernetes/files/sriov/sriov.conf
    - user: root
    - group: root
    - mode: 644
    - makedirs: true
    - dir_mode: 755
    - template: jinja
    - defaults:
        sriov_interface: {{ pool.network.sriov.interface }}
        sriov_subnet: {{ pool.network.sriov.subnet }}
        sriov_gateway: {{ pool.network.sriov.gateway }}

/opt/cni/bin/sriov:
  file.managed:
    - source: {{ pool.network.sriov.source }}
    - source_hash: {{ pool.network.sriov.source_hash }}
    - user: root
    - group: root
    - mode: 751
    - makedirs: true
    {%- if grains.get('noservices') %}
    - onlyif: /bin/false
    {%- endif %}

{%- endif %}
