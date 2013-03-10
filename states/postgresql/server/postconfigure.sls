{% set pg_version = pillar['postgresql']['version'].replace('.', '_') %}
{% set pg_config_base = '/etc/postgresql/{0}/main'.format(pg_version) %}
{% set pg_config_source = 'postgresql/server/{0}/files'.format(pg_version) %}
{% set pg_data_base = '/srv/pgsql/{0}'.format(pg_version) %}
{% set shell_cmd = "awk '$3 ~ /ext/ && $2 ~ /{0}/ { print $2 }' /proc/mounts".format(pg_data_base.replace('/', '\/')) %}

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

p