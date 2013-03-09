git:
  cmd.run:
    - name: adduser --system --home /var/www/gitorious/ --no-create-home --group --shell /bin/bash git
    - unless: getent passwd git
    - order: 1
  user.present:
    - system: True
    - home: /var/www/gitorious/
    - shell: /bin/bash
    - require:
      - cmd.run: git
