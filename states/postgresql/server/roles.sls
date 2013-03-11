include:
  - postgresql.server

{% for role in pillar.get('postgresql.roles', {}).get('absent', []) %}
postgres_role_{{ role }}:
  postgres_user.absent:
    - runas: postgres
    - name: {{ role }}
    - require:
      - service.running: postgresql
{% endfor %}

{% for role, role_config in pillar.get('postgresql.roles', {}).get('present', {}).iteritems() %}
postgres_role_{{ role }}:
  postgres_user.present:
    - runas: postgres
    - require:
      - service.running: postgresql
    - name: {{ role }}
    - createdb: {{ role_config.get('createdb') }}
    - createuser: {{ role_config.get('createuser') }}
    - encrypted: {{ role_config.get('encrypted') }}
    - superuser: {{ role_config.get('superuser') }}
    - password: {{ role_config.get('password') }}
{% endfor %}

