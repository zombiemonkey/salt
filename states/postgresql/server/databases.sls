include:
  - postgresql.server

{% for database in pillar.get('postgresql.databases', {}).get('absent', []) %}
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

