include:
  - repo.ubuntu.postgresql

postgresql_client_packages:
  pkg.installed:
    - pkgs:
{% if pillar.postgresql.version == '9.2' %}
      - postgresql-client-9.2
{% endif %}
    - require:
      - file.exists: postgresql_repository
  cmd.wait:
    - name: /sbin/ldconfig
    - watch:
      - pkg.installed: postgresql_client_packages
    - stateful: False
