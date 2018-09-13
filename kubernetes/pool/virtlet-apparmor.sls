{%- from "kubernetes/map.jinja" import common with context -%}
{%- if common.addons.get('virtlet', {}).get('enabled') and common.addons.get('virtlet', {}).get('use_apparmor', False) %}

{%- set apparmor_profiles = ['libvirtd', 'virtlet', 'vms'] %}

{%- for profile in apparmor_profiles %}

/etc/apparmor.d/{{ profile }}:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/virtlet/apparmor/{{ profile }}
    - user: root
    - group: root
    - mode: '0644'

{%- endfor %}

/etc/apparmor.d/abstractions/libvirt-qemu:
  file.managed:
    - source: salt://kubernetes/files/kube-addons/virtlet/apparmor/libvirt-qemu
    - user: root
    - group: root
    - mode: '0644'

apparmor:
  service.running:
    - watch:
      - file: /etc/apparmor.d/*
      - file: /etc/apparmor.d/abstractions/libvirt-qemu

{% endif %}
