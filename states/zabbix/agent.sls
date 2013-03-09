zabbix-agent:
  pkg.installed: []
  service.running:
    - require:
      - pkg.installed: zabbix-agent
