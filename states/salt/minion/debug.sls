include:
  - salt.minion

/opt/salt/debug:
  file.managed:
    - source: salt://salt/minion/files/defaults/debug.txt
    - template: jinja
    - user: root
    - group: root
    - mode: 600
    - order: 1
    - require:
      - file.directory: /opt/salt
