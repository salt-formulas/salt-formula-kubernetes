{%- from "kubernetes/map.jinja" import master with context %}
include:
- kubernetes.master.service
- kubernetes.master.kube-addons
{%- if master.network.get('flannel', {}).get('enabled', False) %}
- kubernetes.master.flannel
{%- endif %}
{%- if master.network.get('opencontrail', {}).get('enabled', False) %}
- kubernetes.master.opencontrail
{%- endif %}
{%- if master.network.get('calico', {}).get('enabled', False) %}
{%- if not pillar.kubernetes.pool is defined %}
- kubernetes.master.calico
{%- endif %}
{%- endif %}
{%- if master.network.get('genie', {}).get('enabled', False) %}
{%- if not pillar.kubernetes.pool is defined %}
- kubernetes.master.genie
{%- endif %}
{%- endif %}
{%- if master.network.get('sriov', {}).get('enabled', False) %}
- kubernetes.master.sriov
{%- endif %}
{%- if master.storage.get('engine', 'none') == 'glusterfs' %}
- kubernetes.master.glusterfs
{%- endif %}
- kubernetes.master.controller
- kubernetes.master.setup
