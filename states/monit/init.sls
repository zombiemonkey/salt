monit:
  pkg.installed: []
  service.running:
    - enable: True
    - require:
      - pkg.installed: monit
      - file.sed: /etc/default/monit
      - file.append: /etc/monit/monitrc
    - watch:
      - file.append: /etc/monit/monitrc
  file.append:
    - name: /etc/monit/monitrc
    - text:
      - set daemon 30
      - include /etc/monit/conf.d/*

/etc/default/monit:
  file.sed:
{% if grains['oscodename'] == 'precise' %}
    - before: 'no'
    - after: 'yes'
    - limit: '^START='
{% else %}
    - before: 0
    - after: 1
    - limit: ^startup=
{% endif %}
