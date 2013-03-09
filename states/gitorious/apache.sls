/etc/apache2/sites-available/gitorious:
  file.managed:
    - source: salt://gitorious/files/default/vhost_gitorious
    - template: jinja
    - user: root
    - group: root
    - mode: 644

/etc/apache2/sites-available/gitorious-ssl:
  file.managed:
    - source: salt://gitorious/files/default/vhost_gitorious-ssl
    - user: root
    - group: root
    - mode: 644

/etc/apache2/sites-enabled/gitorious:
  file.symlink:
    - target: /etc/apache2/sites-available/gitorious
    - require:
      - file.managed: /etc/apache2/sites-available/gitorious

/etc/apache2/sites-enabled/gitorious-ssl:
  file.symlink:
    - target: /etc/apache2/sites-available/gitorious-ssl
    - require:
      - file.managed: /etc/apache2/sites-available/gitorious-ssl

/etc/apache2/sites-enabled/default:
  file.absent

/etc/apache2/sites-enabled/default-ssl:
  file.absent

{% for modname in [ 'passenger', 'rewrite', 'ssl' ] %}
  {% for extension in [ 'conf', 'load' ] %}
/etc/apache2/mods-enabled/{{ modname }}.{{ extension }}:
  file.symlink:
    - target: /etc/apache2/mods-available/{{ modname }}.{{ extension }}
  {% endfor %}
{% endfor %}

restart_apache2:
  module.wait:
    - name: service.restart
    - m_name: apache2
    - watch:
      - file.absent: /etc/apache2/sites-enabled/default
      - file.absent: /etc/apache2/sites-enabled/default-ssl
      - file.managed: /etc/apache2/sites-available/gitorious
      - file.managed: /etc/apache2/sites-available/gitorious-ssl
{% for modname in [ 'passenger', 'rewrite', 'ssl' ] %}
  {% for extension in [ 'conf', 'load' ] %}
      - file.symlink: /etc/apache2/mods-enabled/{{ modname }}.{{ extension }}
  {% endfor %}
{% endfor %}
       
