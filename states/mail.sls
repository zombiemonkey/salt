postfix:
  pkg.installed:
    - name: mailutils
  service.running:
    - require:
      - pkg.installed: mailutils

root:
  alias.present:
    - target: jasong@godden.id.au
    - require:
      - pkg.installed: mailutils

