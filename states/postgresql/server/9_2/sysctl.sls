kernel.shmmax:
  sysctl.present:
    - value: {{ grains['mem_total'] * 1024 * 1024 }}

kernel.shmall:
  sysctl.present:
    - value: {{ (grains['mem_total'] * 1024 * 1024) // 4096 }}
