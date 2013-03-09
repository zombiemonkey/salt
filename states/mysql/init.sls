mysql-server:
  pkg.installed:
    - pkgs:
      - mysql-server
      - python-mysqldb
  file.managed:
    - name: /etc/mysql/my.cnf
    - source: salt://mysql/files/hosts/{{ grains.id }}/my.cnf
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
  mysql_user.present:
    - name: admin
    - host: localhost
    - password: foobar
    - require:
      - service.running: mysql-server
  mysql_grants.present:
    - grant: all privileges
    - database: '*.*'
    - user: admin
    - host: localhost
    - require:
      - mysql_user.present: admin

gitorious:
  mysql_database.present:
    - require:
      - service.running: mysql-server
  mysql_user.present:
    - host: master.localmonkey
    - password: hi3Shaa1
    - require:
      - service.running: mysql-server
  mysql_grants.present:
    - grant: all privileges
    - database: gitorious.*
    - user: gitorious
    - require:
      - mysql_database.present: gitorious
      - mysql_user.present: gitorious

