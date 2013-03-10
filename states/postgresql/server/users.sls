include:
  - postgresql.server

{% for user in pillar.get('postgresql.roles').get('absent', []) %}
postgres_user_{{ user }}:
  postgres_user.absent:
    - runas: postgres
    - name: {{ user }}
    - require:
      - service.running: postgresql
{% endfor %}

{% for user, user_config in pillar.get('postgresql.roles', {}).get('present', {}).iteritems() %}
postgres_user_{{ user }}:
  postgres_user.present:
    - runas: postgres
    - require:
      - service.running: postgresql
    - name: {{ user }}
    - createdb: {{ user_config.get('createdb') }}
    - createuser: {{ user_config.get('createuser') }}
    - encrypted: {{ user_config.get('encrypted') }}
    - superuser: {{ user_config.get('superuser') }}
    - password: {{ user_config.get('password') }}
{% endfor %}

