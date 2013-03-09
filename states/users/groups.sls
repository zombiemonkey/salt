admin:
  group.present:
    - system: True

sudo:
  group.present:
    - gid: 27
    - system: True
