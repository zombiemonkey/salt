include:
  - postgresql.server.9_2

/etc/postgresql/9.2/main:
  file.directory:
    - user: root
    - group: postgres
    - mode: 700
    - require:
      - cmd.run: pg_createcluster

/data/pgsql/9.2:
  file.directory:
    - user: postgres
    - group: postgres
    - mode: 700
    - makedirs: True
    - recurse:
      - user
      - group

/data/pgsql/9.2/system:
  file.exists:
    - require:
      - file.directory: /data/pgsql/9.2

/data/pgsql/9.2/wal:
  file.exists:
    - require:
      - file.directory: /data/pgsql/9.2

clean_lost+found:
  cmd.run:
    - name: find /data/pgsql/9.2/system /data/pgsql/9.2/wal -type d -name 'lost+found' -delete
    - onlyif:
        test `find /data/pgsql/9.2/system /data/pgsql/9.2/wal -type d -name 'lost+found' | wc -l` -gt 0 &&
        test ! -f /data/pgsql/9.2/system/PG_VERSION &&
        test ! -f /data/pgsql/9.2/wal/archive_status
    - require:
      - file.exists: /data/pgsql/9.2/system
      - file.exists: /data/pgsql/9.2/wal

pg_createcluster:
  cmd.run:
    - name: pg_createcluster -u postgres -g postgres --locale C -e UNICODE 9.2 main
    - onlyif: test ! -f /data/pgsql/9.2/system/PG_VERSION
    - require:
      - pkg.installed: postgresql_server_packages
      - cmd.run: clean_lost+found

pre_relocate_pg_xlog:
  cmd.run:
    - name: service postgresql stop
    - onlyif:
        test ! -L /data/pgsql/9.2/system/pg_xlog &&
        service postgresql status
    - require:
      - pkg.installed: postgresql_server_packages
      - cmd.run: pg_createcluster

relocate_pg_xlog:
  cmd.run:
    - name:
        mv /data/pgsql/9.2/system/pg_xlog/* /data/pgsql/9.2/wal/ &&
        rm -r /data/pgsql/9.2/system/pg_xlog &&
        ln -s /data/pgsql/9.2/wal /data/pgsql/9.2/system/pg_xlog &&
        chown -h postgres.postgres /data/pgsql/9.2/system/pg_xlog
    - onlyif: test ! -L /data/pgsql/9.2/system/pg_xlog
    - require:
      - cmd.run: pre_relocate_pg_xlog

