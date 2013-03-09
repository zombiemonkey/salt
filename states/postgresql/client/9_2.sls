include:
  - repo.ubuntu.postgresql

postgresql_client_packages:
  pkg.installed:
    - names:
      - postgresql-client-9.2
    - require:
      - file.exists: postgresql_repository
  cmd.wait:
    - name: /sbin/ldconfig
    - watch:
      - pkg.installed: postgresql_client_packages
    - stateful: False
