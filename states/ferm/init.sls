ferm:
  pkg.installed: []
  service.running:
    - enable: True
    - watch:
      - file.managed: /etc/ferm/ferm.conf
  file.managed:
    - name: /etc/ferm/ferm.conf
    - source:
      - salt://ferm/files/hosts/{{ grains.id }}/ferm.conf
      - salt://ferm/files/default/ferm.conf
    - user: root
    - group: root
    - require:
      - pkg.installed: ferm
