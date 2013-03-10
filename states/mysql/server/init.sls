mysql-server:
  pkg.installed:
    - pkgs:
      - mysql-server
      - python-mysqldb
  file.managed:
    - name: /etc/mysql/my.cnf
    - source: salt://mysql/server/files/hosts/{{ grains.id }}_my.cnf
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg.installed: mysql-server
  service.running:
    - name: mysql
    - enable: True
    - watch:
      - file.managed: /etc/mysql/my.cnf

phpmyadmin:
  pkg.installed:
    - require:
      - pkg.installed: mysql-server 
  file.symlink:
    - name: /etc/apache2/sites-enabled/phpmyadmin.conf
    - target: /etc/phpmyadmin/apache.conf
    - require:
      - pkg.installed: phpmyadmin
  module.wait:
    - name: apache.signal
    - signal: restart
    - watch:
      - file.symlink: /etc/apache2/sites-enabled/phpmyadmin.conf

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

{% for database in pillar.get('mysql.databases', []) %}
mysql_database_{{ database }}:
  mysql_database.present:
    - require:
      - service.running: mysql-server
{% endfor %}
