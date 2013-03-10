{% set pg_version = pillar['postgresql']['version'].replace('.', '_') %}
{% set pg_config_base = '/etc/postgresql/{0}/main'.format(pg_version) %}
{% set pg_config_source = 'postgresql/server/{0}/files'.format(pg_version) %}
{% set pg_data_base = '/srv/pgsql/{0}'.format(pg_version) %}

include:
  - postgresql.server.{{ pg_version }}

{% for database in pillar.get('postgresql.databases').get('absent', []) %}
postgres_database_{{ database }}:
  postgres_database.absent:
    - runas: postgres
    - name: {{ database }}
    - require:
      - service.running: postgresql
{% endfor %}

{% for database, database_config in pillar.get('postgresql.databases', {}).get('present', {}).iteritems() %}
postgres_database_{{ database }}:
  postgres_database.present:
    - runas: postgres
    - require:
      - service.running: postgresql
    - name: {{ database }}
    - tablespace: {{ database_config.get('tablespace') }}
    - encoding: {{ database_config.get('encoding') }}
    - locale: {{ database_config.get('locale') }}
    - lc_collate: {{ database_config.get('lc_collate') }}
    - lc_ctype: {{ database_config.get('lc_ctype') }}
    - owner: {{ database_config.get('owner') }}
    - template: {{ database_config.get('template') }}
{% endfor %}

