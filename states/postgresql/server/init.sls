{% set pg_config_base = '/etc/postgresql/{0}/main'.format(pillar['postgresql']['version']) %}
{% set pg_config_source = 'postgresql/server/{0}/files'.format(pillar['postgresql']['version']) %}

include:
  - postgresql.server.packages
  - postgresql.server.initdb
  - postgresql.server.postconfigure

kernel.shmmax:
  sysctl.present:
    - value: {{ grains.mem_total * 1024 * 1024 }}

kernel.shmall:
  sysctl.present:
    - value: {{ (grains.mem_total * 1024 * 1024) // 4096 }}

vm.overcommit:
  sysctl.present:
    - value: 2

postgresql:
  service.running:
    - enable: True
    - require:
      - pkg.installed: postgresql_server_packages
      - file.managed: {{ pg_config_base }}/postgresql.conf
      - file.managed: {{ pg_config_base }}/pg_hba.conf
      - file.managed: {{ pg_config_base }}/pg_ident.conf
      - sysctl.present: kernel.shmmax
      - sysctl.present: kernel.shmall
      - sysctl.present: vm.overcommit
      - cmd.run: relocate_pg_xlog
  cmd.wait:
    - name: service postgresql reload
    - stateful: False
    - require:
      - service.running: postgresql
    - watch:
      - file.managed: {{ pg_config_base }}/postgresql.conf
      - file.managed: {{ pg_config_base }}/pg_hba.conf
      - file.managed: {{ pg_config_base }}/pg_ident.conf

{{ pg_config_base }}/postgresql.conf:
  file.managed:
    - source:
      - salt://{{ pg_config_source }}/hosts/{{ grains.host }}.postgresql.conf
      - salt://{{ pg_config_source }}/defaults/postgresql.conf
    - user: postgres
    - group: postgres
    - mode: 644
    - require:
      - cmd.run: pg_createcluster
      - file.directory: {{ pg_config_base }}

{{ pg_config_base }}/pg_hba.conf:
  file.managed:
{% if pillar.get('postgresql').get('hba') %}
    - template: jinja
    - source: salt://{{ pg_config_source }}/templates/pg_hba.conf
{% else %}
    - source:
      - salt://{{ pg_config_source }}/hosts/{{ grains.host }}.pg_hba.conf
      - salt://{{ pg_config_source }}/defaults/pg_hba.conf
{% endif %}
    - user: postgres
    - group: postgres
    - mode: 640
    - require:
      - cmd.run: pg_createcluster
      - file.directory: {{ pg_config_base }}

{{ pg_config_base }}/pg_ident.conf:
  file.managed:
    - source:
      - salt://{{ pg_config_source }}/hosts/{{ grains.host }}.pg_ident.conf
      - salt://{{ pg_config_source }}/defaults/pg_ident.conf
    - user: postgres
    - group: postgres
    - mode: 640
    - require:
      - cmd.run: pg_createcluster
      - file.directory: {{ pg_config_base }}
