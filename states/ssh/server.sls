openssh-server:
  pkg.installed: []
  file.managed:
    - name: /etc/ssh/sshd_config
    - source: salt://ssh/files/hosts/{{ grains.id }}.sshd_config
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg.installed: openssh-server
  service.running:
    - name: ssh
    - watch:
      - file.managed: /etc/ssh/sshd_config
    - require:
      - pkg.installed: openssh-server
