{%- from "kubernetes/map.jinja" import pool with context %}
{%- if pool.enabled %}

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
        hostname: {{ pool.host.name }}{% if pool.host.get('domain') %}.{{ pool.host.domain }}{%- endif %}
        {%- if pool.network.genie.default_plugin is defined %}
        default_plugin: {{ pool.network.genie.default_plugin }}
        {%- endif %}

/opt/cni/bin/genie:
  file.managed:
    - source: {{ pool.network.genie.source }}
    - source_hash: {{ pool.network.genie.source_hash }}
    - mode: 751
    - user: root
    - group: root
    {%- if grains.get('noservices') %}
    - onlyif: /bin/false
    {%- endif %}

{%- endif %}
