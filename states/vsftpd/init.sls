vsftpd:
  pkg.installed: []
  service:
    - running
    - require:
      - pkg.installed: vsftpd
      - file.managed: /etc/vsftpd.conf
    - watch:
      - file.managed: /etc/vsftpd.conf

/etc/vsftpd.conf:
  file.managed:
    - source: salt://vsftpd/files/vsftpd.conf 
    - user: root
    - group: root
    - mode: 644
