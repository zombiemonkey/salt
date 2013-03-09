include:
  - postgresql.server.9_2

{% for dirname in salt['cmd.run']('ls /data/pgsql/9.2/data').split() %}
remove_lost+found_{{ dirname }}:
  cmd.run:
    - name: rmdir /data/pgsql/9.2/data/{{ dirname }}/lost+found
    - onlyif:
        test ! -d /data/pgsql/9.2/data/{{ dirname }}/PG_9.2_201204301 &&
        test -d /data/pgsql/9.2/data/{{ dirname }}/lost+found

create_tablespace_{{ dirname }}:
  cmd.run:
    - name:
        psql -c "CREATE TABLESPACE {{ dirname }} OWNER postgres LOCATION '/data/pgsql/9.2/data/{{ dirname }}'" &&
        psql -c "GRANT CREATE ON TABLESPACE {{ dirname }} TO PUBLIC"
    - unless: test -d /data/pgsql/9.2/data/{{ dirname }}/PG_9.2_201204301
    - user: postgres
    - cwd: /
    - require:
      - service.running: postgresql
      - cmd.run: remove_lost+found_{{ dirname }}

  {% if dirname == 'vol1' %}
relocate_template1:
  cmd.run:
    - name:
        psql -c "UPDATE pg_database SET datistemplate = false WHERE datname = 'template1'" &&
        psql -c "ALTER DATABASE template1 RENAME TO template1_old" &&
        psql -c "CREATE DATABASE template1 TEMPLATE template0 OWNER postgres ENCODING 'UTF8' TABLESPACE vol1" &&
        psql -c "ALTER DATABASE template1 SET default_tablespace = 'vol1'" &&
        psql -c "BEGIN;
                  UPDATE pg_database SET datistemplate = true WHERE datname = 'template1';
                  GRANT CONNECT ON DATABASE template1 TO PUBLIC;
                  REVOKE TEMPORARY ON DATABASE template1 FROM PUBLIC; COMMIT" &&
        psql -c "DROP DATABASE template1_old" &&
        psql template1 -c "VACUUM FULL FREEZE ANALYZE"
    - onlyif:
        test `psql -A -t -c "SELECT oid = (SELECT dattablespace FROM pg_database WHERE datname = 'template1') FROM pg_tablespace WHERE spcname = 'pg_default'"` = t
    - user: postgres
    - cwd: /
    - require:
      - cmd.run: create_tablespace_vol1
  {% endif %}
{% endfor %}

