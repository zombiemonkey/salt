include:
  - mysql.server

{% for role in pillar.get('mysql.roles', {}).get('absent', []) %}
mysql_role_{{ role }}:
  mysql_user.absent:
    - name: {{ role }}
    - require:
      - service.running: mysql-server
{% endfor %}

{% for role, role_config in pillar.get('mysql.roles', {}).get('present', {}).iteritems() %}
mysql_role_{{ role }}:
  mysql_user.present:
    - name: {{ role }}
    - host: {{ role_config.host }}
    - password: {{ role_config.password }}
    - require:
      - service.running: mysql-server
  mysql_grants.present:
    - grant: {{ role_config.grant }}
    - database: {{ role_config.grant_database }}
    - user: {{ role }}
    - host: {{ role_config.host }}
    - require:
      - mysql_user.present: mysql_role_{{ role }}
{% endfor %}
