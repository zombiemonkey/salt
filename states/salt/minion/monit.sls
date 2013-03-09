include:
  - monit
  - salt.minion

/etc/monit/conf.d/salt-minion:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://salt/minion/files/defaults/salt-minion.monit
    - watch_in:
      - service: monit
    - require:
      - service.running: salt-minion
