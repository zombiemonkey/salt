{% set pg_data_base = '/srv/pgsql/{0}'.format(pillar['postgresql']['version']) %}
{% set shell_cmd = "awk '$3 ~ /ext/ && $2 ~ /{0}/ { print $2 }' /proc/mounts".format(pg_data_base.replace('/', '\/')) %}

include:
  - postgresql.server

{% for dirname in salt['cmd.run'](shell_cmd).split() %}
recreate_lost+found_{{ dirname }}:
  cmd.run:
    - name: mklost+found
    - cwd: {{ dirname }}
    - onlyif:
        test ! -d {{ dirname }}/lost+found
    - order: last
    - require:
      - service.running: postgresql
{% endfor %}
