include:
  - gitorious.packages 

gitorious:
  git.latest:
    - name: git://gitorious.org/gitorious/mainline.git
    - target: /var/www/gitorious
    - require:
      - pkg.installed: gitorious_packages
      - pkg.installed: gitorious_sphinx_packages
      - pkg.installed: gitorious_ruby_packages
  cmd.wait:
    - name:
        git submodule init &&
        git submodule update &&
        bundle install &&
        bundle pack 
    - cwd: /var/www/gitorious
    - watch:
      - git.latest: git://gitorious.org/gitorious/mainline.git
  file.symlink:
    - name: /usr/bin/gitorious
    - target: /var/www/gitorious/script/gitorious
    - watch:
      - cmd.wait: gitorious

gitorious_configure_init:
  cmd.wait:
    - name:
        cp git-daemon git-poller git-ultrasphinx stomp /etc/init.d/ && 
        cp gitorious-logrotate /etc/logrotate.d/
    - cwd: /var/www/gitorious/doc/templates/ubuntu
    - watch:
      - cmd.wait: gitorious

{% for service in [ 'git-daemon', 'git-poller', 'git-ultrasphinx', 'stomp' ] %}
{{ service }}_enabled:
  service.enabled:
    - name: {{ service }}
    - require:
      - cmd.wait: gitorious_configure_init
{% endfor %}

/opt/ruby-enterprise:
  file.symlink:
    - target: /usr/

{% for dirname in [ 'tmp/pids', 'repositories', 'tarballs' ] %}
/var/www/gitorious/{{ dirname }}:
  file.directory:
    - user: git
    - group: git
    - recurse:
      - user
      - group
    - require:
      - git.latest: git://gitorious.org/gitorious/mainline.git
{% endfor %}

/var/www/gitorious/.ssh:
  file.directory:
    - user: git
    - group: git
    - mode: 700
    - require:
      - git.latest: git://gitorious.org/gitorious/mainline.git

/var/www/gitorious/.ssh/authorized_keys:
  file.touch:
    - require:
      - file.directory: /var/www/gitorious/.ssh

/var/www/gitorious:
  file.directory:
    - user: git
    - group: git
    - require:
      - file.touch: /var/www/gitorious/.ssh/authorized_keys
      - file.symlink: /opt/ruby-enterprise
{% for dirname in [ 'tmp/pids', 'repositories', 'tarballs' ] %}
      - file.directory: /var/www/gitorious/{{ dirname }}
{% endfor %}

/var/www/gitorious/config/database.yml:
  file.managed:
    - source: salt://gitorious/files/default/database.yml
    - user: git
    - group: git
    - require:
      - file.directory: /var/www/gitorious

/var/www/gitorious/config/gitorious.yml:
  file.managed:
    - source: salt://gitorious/files/default/gitorious.yml
    - user: git
    - group: git
    - require:
      - file.directory: /var/www/gitorious

/var/www/gitorious/config/broker.yml:
  file.managed:
    - source: salt://gitorious/files/default/broker.yml
    - user: git
    - group: git
    - require:
      - file.directory: /var/www/gitorious

/var/www/gitorious/config/environment.rb:
  file.managed:
    - source: salt://gitorious/files/default/environment.rb
    - user: git
    - group: git
    - require:
      - file.directory: /var/www/gitorious

initialize_db:
  cmd.run:
    - name:
      mv config/boot.rb config/boot.bak &&
      echo "require 'thread'" >> config/boot.rb &&
      cat config/boot.bak >> config/boot.rb &&
      export RAILS_ENV=production &&
      bundle exec rake db:create &&
      bundle exec rake db:migrate &&
      bundle exec rake thinking_sphinx:configure &&
      bundle exec rake thinking_sphinx:index
    - runas: git
    - cwd: /var/www/gitorious
    - require:
      - file.managed: /var/www/gitorious/config/database.yml
      - file.managed: /var/www/gitorious/config/gitorious.yml
      - file.managed: /var/www/gitorious/config/broker.yml
      - file.managed: /var/www/gitorious/config/environment.rb
  

