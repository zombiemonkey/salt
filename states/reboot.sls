/sbin/reboot:
  cmd.run:
    - onlyif: test -f /var/run/reboot-required
    - order: last
