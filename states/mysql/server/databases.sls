include:
  - mysql.server

{% for database in pillar.get('mysql.databases', []) %}
mysql_database_{{ database }}:
  mysql_database.present:
    - require:
      - service.running: mysql-server
{% endfor %}

