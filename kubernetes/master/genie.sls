{%- from "kubernetes/map.jinja" import master with context %}
{%- if master.enabled %}

{%- if not pillar.kubernetes.pool is defined %}

/etc/cni/net.d/00-genie.conf:
  file.managed:
    - source: salt://kubernetes/files/genie/genie.conf
    - user: root
    - group: root
    - mode: 644
    - makedirs: true
    - dir_mode: 755
    - template: jinja
    - defaults:
        hostname: {{ master.host.name }}{% if master.host.get('domain') %}.{{ master.host.domain }}{%- endif %}
        {%- if master.network.genie.default_plugin is defined %}
        default_plugin: {{ master.network.genie.default_plugin }}
        {%- endif %}

/opt/cni/bin/genie:
  file.managed:
    - source: {{ master.network.genie.source }}
    - source_hash: {{ master.network.genie.source_hash }}
    - mode: 751
    - user: root
    - group: root
    {%- if grains.get('noservices') %}
    - onlyif: /bin/false
    {%- endif %}

{%- endif %}

{%- endif %}
