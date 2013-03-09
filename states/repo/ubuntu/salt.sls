include:
  - packages

salt_repository:
  cmd.run:
    - name: add-apt-repository -y ppa:saltstack/salt && apt-get update
    - unless:
        test -f /etc/apt/sources.list.d/saltstack-salt-{{ grains['oscodename'] }}.list &&
        test `apt-key list | grep 1024R/0E27C0A6 | wc -l` -eq 1
    - require:
      - pkg.installed: default_packages
  file.exists:
    - name: /etc/apt/sources.list.d/saltstack-salt-{{ grains['oscodename'] }}.list
    - require:
      - cmd.run: salt_repository
