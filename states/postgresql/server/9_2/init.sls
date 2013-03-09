include:
  - postgresql.server.9_2.packages
  - postgresql.server.9_2.sysctl
  - postgresql.server.9_2.initdb
  - postgresql.server.9_2.postconfigure

postgresql:
  service.running:
    - enable: True
    - require:
      - pkg.installed: postgresql_server_packages
      - file.managed: /etc/postgresql/9.2/main/postgresql.conf
      - file.managed: /etc/postgresql/9.2/main/pg_hba.conf
      - file.managed: /etc/postgresql/9.2/main/pg_ident.conf
      - sysctl.present: kernel.shmmax
      - sysctl.present: kernel.shmall
      - cmd.run: relocate_pg_xlog
  cmd.wait:
    - name: service postgresql reload
    - stateful: False
    - require:
      - service.running: postgresql
    - watch:
      - file.managed: /etc/postgresql/9.2/main/postgresql.conf
      - file.managed: /etc/postgresql/9.2/main/pg_hba.conf
      - file.managed: /etc/postgresql/9.2/main/pg_ident.conf

/etc/postgresql/9.2/main/postgresql.conf:
  file.managed:
    - source:
      - salt://postgresql/server/9_2/files/hosts/{{ grains['host'] }}.postgresql.conf
      - salt://postgresql/server/9_2/files/defaults/postgresql.conf
    - user: postgres
    - group: postgres
    - mode: 644
    - require:
      - cmd.run: pg_createcluster
      - file.directory: /etc/postgresql/9.2/main

/etc/postgresql/9.2/main/pg_hba.conf:
  file.managed:
{% if "postgresql.hba" in pillar %}
    - template: jinja
    - source: salt://postgresql/server/9_2/files/templates/pg_hba.conf
{% else %}
    - source:
      - salt://postgresql/server/9_2/files/hosts/{{ grains['host'] }}.pg_hba.conf
      - salt://postgresql/server/9_2/files/defaults/pg_hba.conf
{% endif %}
    - user: postgres
    - group: postgres
    - mode: 640
    - require:
      - cmd.run: pg_createcluster
      - file.directory: /etc/postgresql/9.2/main

/etc/postgresql/9.2/main/pg_ident.conf:
  file.managed:
    - source:
      - salt://postgresql/server/9_2/files/hosts/{{ grains['host'] }}.pg_ident.conf
      - salt://postgresql/server/9_2/files/defaults/pg_ident.conf
    - user: postgres
    - group: postgres
    - mode: 640
    - require:
      - cmd.run: pg_createcluster
      - file.directory: /etc/postgresql/9.2/main

