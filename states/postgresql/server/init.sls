{% set pg_config_base = '/etc/postgresql/{0}/main'.format(pillar['postgresql']['version']) %}
{% set pg_config_source = 'postgresql/server/{0}/files'.format(pillar['postgresql']['version']) %}
{% set pg_config_files = [ 'postgresql.conf', 'pg_ctl.conf', 'pg_ident.conf', 'start.conf' ] %}

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
      - file.managed: {{ pg_config_base }}/pg_hba.conf
{% for config_file in pg_config_files %}
      - file.managed: {{ pg_config_base }}/{{ config_file }}
{% endfor %}
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
      - file.managed: {{ pg_config_base }}/pg_hba.conf
{% for config_file in pg_config_files %}
      - file.managed: {{ pg_config_base }}/{{ config_file }}
{% endfor %}

{% for config_file in pg_config_files %}
{{ pg_config_base }}/{{ config_file }}:
  file.managed:
    - source:
      - salt://{{ pg_config_source }}/hosts/{{ grains.host }}_{{ config_file }}
      - salt://{{ pg_config_source }}/defaults/{{ pillar.postgresql.version }}_{{ config_file }}
    - user: postgres
    - group: postgres
    - mode: 644
    - require:
      - cmd.run: pg_createcluster
      - file.directory: {{ pg_config_base }}
{% endfor %}
      
{{ pg_config_base }}/pg_hba.conf:
  file.managed:
{% if pillar.get('postgresql.hba') %}
    - template: jinja
    - source: salt://{{ pg_config_source }}/templates/pg_hba.conf
{% else %}
    - source:
      - salt://{{ pg_config_source }}/hosts/{{ grains.host }}_pg_hba.conf
      - salt://{{ pg_config_source }}/defaults/{{ pillar.postgresql.version }}_pg_hba.conf
{% endif %}
    - user: postgres
    - group: postgres
    - mode: 640
    - require:
      - cmd.run: pg_createcluster
      - file.directory: {{ pg_config_base }}
