{% set SHELL_CMD = "awk '$3 ~ /ext/ && $2 ~ /\/data\/pgsql\/9.2/ { print $2 }' /proc/mounts" %}
{% for dirname in salt['cmd.run'](SHELL_CMD).split() %}
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

