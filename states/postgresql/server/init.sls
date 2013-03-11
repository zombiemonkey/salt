{% set pg_config_base = '/etc/postgresql/{0}/main'.format(pillar['postgresql']['version']) %}
{% set pg_config_files = [ 'pg_ctl.conf', 'pg_ident.conf', 'start.conf' ] %}

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
      - file.managed: {{ pg_config_base }}/postgresql.conf
{% if pillar.get('postgresql', {}).get('config', {}) %}
      - file.managed: {{ pg_config_base }}/options.conf
{% endif %}
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
      - file.managed: {{ pg_config_base }}/postgresql.conf
{% if pillar.get('postgresql', {}).get('config', {}) %}
      - file.managed: {{ pg_config_base }}/options.conf
{% endif %}
{% for config_file in pg_config_files %}
      - file.managed: {{ pg_config_base }}/{{ config_file }}
{% endfor %}

{% for config_file in pg_config_files %}
{{ pg_config_base }}/{{ config_file }}:
  file.managed:
    - source:
      - salt://postgresql/server/files/hosts/{{ grains.host }}_{{ config_file }}
      - salt://postgresql/server/files/defaults/{{ pillar.postgresql.version }}_{{ config_file }}
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
    - source: salt://postgresql/server/files/templates/pg_hba.conf
{% else %}
    - source:
      - salt://postgresql/server/files/hosts/{{ grains.host }}_pg_hba.conf
      - salt://postgresql/server/files/defaults/{{ pillar.postgresql.version }}_pg_hba.conf
{% endif %}
    - user: postgres
    - group: postgres
    - mode: 640
    - require:
      - cmd.run: pg_createcluster
      - file.directory: {{ pg_config_base }}

{{ pg_config_base }}/postgresql.conf:
  file.managed:
{% if pillar.get('postgresql', {}).get('config', {}) %}
    - template: jinja
    - source: salt://postgresql/server/files/templates/postgresql.conf
{% else %}
    - source:
      - salt://postgresql/server/files/hosts/{{ grains.host }}_postgresql.conf
      - salt://postgresql/server/files/defaults/{{ pillar.postgresql.version }}_postgresql.conf
{% endif %}
    - user: postgres
    - group: postgres
    - mode: 640
    - require:
      - cmd.run: pg_createcluster
      - file.directory: {{ pg_config_base }}

{% if pillar.get('postgresql', {}).get('config', {}) %}
{{ pg_config_base }}/options.conf:
  file.managed:
    - template: jinja
    - source: salt://postgresql/server/files/templates/options.conf
    - user: postgres
    - group: postgres
    - mode: 640
    - require:
      - file.managed: {{ pg_config_base }}/postgresql.conf
{% endif %}
