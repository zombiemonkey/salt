include:
  - salt

salt-minion:
  pkg.installed:
    - require:
      - file.exists: salt_repository
  service.running:
    - enable: True
    - order: 1
    - require:
      - pkg.installed: salt-minion
      - file.managed: /etc/salt/minion.d/general.conf
      - file.managed: /etc/salt/minion.d/options.conf
      - sysctl.present: net.core.rmem_max
      - sysctl.present: net.core.wmem_max
      - sysctl.present: net.ipv4.tcp_rmem
      - sysctl.present: net.ipv4.tcp_wmem
      - file.append: /etc/security/limits.conf
      - file.directory: /opt/salt
    - watch:
      - file.managed: /etc/salt/minion.d/general.conf
      - file.managed: /etc/salt/minion.d/options.conf
  file.directory:
    - name: /etc/salt/minion.d
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg.installed: salt-minion

/etc/salt/minion.d/general.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 600
    - require:
      - file.directory: /etc/salt/minion.d
    - source: salt://salt/minion/files/defaults/general.conf

/etc/salt/minion.d/options.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 600
    - require:
      - file.directory: /etc/salt/minion.d
    - source:
      - salt://salt/minion/files/hosts/{{ grains.id }}_options.conf
      - salt://salt/minion/files/defaults/options.conf

/etc/security/limits.conf:
  file.append:
    - text:
      - "*      soft     nofile      100000"
      - "*      hard     nofile      100000"

/opt/salt:
  file.directory:
    - user: root
    - group: root
    - mode: 700
