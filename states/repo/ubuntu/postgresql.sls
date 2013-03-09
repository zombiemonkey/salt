include:
  - packages

postgresql_repository:
  cmd.run:
    - name: add-apt-repository -y ppa:pitti/postgresql && apt-get update
    - unless:
        test -f /etc/apt/sources.list.d/pitti-postgresql-{{ grains['oscodename'] }}.list &&
        test `apt-key list | grep 1024R/8683D8A2 | wc -l` -eq 1
    - require:
      - pkg.installed: default_packages
  file.exists:
    - name: /etc/apt/sources.list.d/pitti-postgresql-{{ grains['oscodename'] }}.list
    - require:
      - cmd.run: postgresql_repository
