{%- from "kubernetes/map.jinja" import master with context %}
{%- if master.enabled %}

{%- if not pillar.kubernetes.pool is defined %}
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
        sriov_interface: {{ master.network.sriov.interface }}
        sriov_subnet: {{ master.network.sriov.subnet }}
        sriov_gateway: {{ master.network.sriov.gateway }}

/opt/cni/bin/sriov:
  file.managed:
    - source: {{ master.network.sriov.source }}
    - source_hash: {{ master.network.sriov.source_hash }}
    - user: root
    - group: root
    - mode: 751
    - makedirs: true
    {%- if grains.get('noservices') %}
    - onlyif: /bin/false
    {%- endif %}

{%- endif %}
{%- endif %}
