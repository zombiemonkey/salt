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
