zabbix:
  pkg.installed:
    - pkgs:
      - zabbix-server-pgsql
      - zabbix-frontend-php
