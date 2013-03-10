postfix:
  pkg.installed:
    - name: mailutils
  service.running:
    - require:
      - pkg.installed: mailutils

root:
  alias.present:
    - target: {{ pillar.alias.root }}
    - require:
      - pkg.installed: mailutils

