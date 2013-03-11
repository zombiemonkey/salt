include:
  - mysql.server

{% for database in pillar.get('mysql.databases', {}).get('absent', []) %}
mysql_database_{{ database }}:
  mysql_database.absent:
    - require:
      - service.running: mysql-server
{% endfor %}

{% for database in pillar.get('mysql.databases', {}).get('present', []) %}
mysql_database_{{ database }}:
  mysql_database.present:
    - require:
      - service.running: mysql-server
{% endfor %}
