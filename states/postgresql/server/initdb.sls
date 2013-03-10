{% set pg_config_base = '/etc/postgresql/{0}/main'.format(pillar['postgresql']['version']) %}
{% set pg_config_source = 'postgresql/server/{0}/files'.format(pillar['postgresql']['version']) %}
{% set pg_data_base = '/srv/pgsql/{0}'.format(pillar['postgresql']['version']) %}
{% set find_cmd = 'find {0}/data -mindepth 1 -maxdepth 1 -type d -printf "%f\n"'.format(pg_data_base) %}

include:
  - postgresql.server

{{ pg_config_base }}:
  file.directory:
    - user: root
    - group: postgres
    - mode: 700
    - require:
      - cmd.run: pg_createcluster

{{ pg_data_base }}:
  file.directory:
    - user: postgres
    - group: postgres
    - dir_mode: 700
    - makedirs: True
    - recurse:
      - user
      - group

{{ pg_data_base }}/system:
  file.exists:
    - require:
      - file.directory: {{ pg_data_base }}

{{ pg_data_base }}/wal:
  file.exists:
    - require:
      - file.directory: {{ pg_data_base }}

clean_lost+found:
  cmd.run:
    - name: find {{ pg_data_base }}/system {{ pg_data_base }}/wal -type d -name 'lost+found' -delete
    - onlyif:
        test `find {{ pg_data_base }}/system {{ pg_data_base }}/wal -type d -name 'lost+found' | wc -l` -gt 0 &&
        test ! -f {{ pg_data_base }}/system/PG_VERSION &&
        test ! -f {{ pg_data_base }}/wal/archive_status
    - require:
      - file.exists: {{ pg_data_base }}/system
      - file.exists: {{ pg_data_base }}/wal

pg_createcluster:
  cmd.run:
    - name: pg_createcluster -u postgres -g postgres --locale C -e UNICODE {{ pillar.postgresql.version }} main
    - onlyif: test ! -f {{ pg_data_base }}/system/PG_VERSION
    - require:
      - pkg.installed: postgresql_server_packages
      - cmd.run: clean_lost+found

pre_relocate_pg_xlog:
  cmd.run:
    - name: service postgresql stop
    - onlyif:
        test ! -L {{ pg_data_base }}/system/pg_xlog &&
        service postgresql status
    - require:
      - pkg.installed: postgresql_server_packages
      - cmd.run: pg_createcluster

relocate_pg_xlog:
  cmd.run:
    - name:
        mv {{ pg_data_base }}/system/pg_xlog/* {{ pg_data_base }}/wal/ &&
        rm -r {{ pg_data_base }}/system/pg_xlog &&
        ln -s {{ pg_data_base }}/wal {{ pg_data_base }}/system/pg_xlog &&
        chown -h postgres.postgres {{ pg_data_base }}/system/pg_xlog
    - onlyif: test ! -L {{ pg_data_base }}/system/pg_xlog
    - require:
      - cmd.run: pre_relocate_pg_xlog
