include:
  - postgresql.client.9_2

postgresql_server_packages:
  pkg.installed:
    - require:
      - pkg.installed: postgresql_client_packages
    - pkgs:
      - postgresql-9.2
      - postgresql-doc-9.2
      - postgresql-contrib-9.2
      - postgresql-plpython-9.2
      - libpgtypes3
      - pgbouncer
      - pgsnap

