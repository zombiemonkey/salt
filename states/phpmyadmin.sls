include:
  - mysql.server

phpmyadmin:
  pkg.installed:
    - require:
      - pkg.installed: mysql-server 
  file.symlink:
    - name: /etc/apache2/sites-enabled/phpmyadmin.conf
    - target: /etc/phpmyadmin/apache.conf
    - require:
      - pkg.installed: phpmyadmin
  module.wait:
    - name: apache.signal
    - signal: restart
    - watch:
      - file.symlink: /etc/apache2/sites-enabled/phpmyadmin.conf

