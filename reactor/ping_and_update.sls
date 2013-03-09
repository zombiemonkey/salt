ping:
  cmd.test.ping:
    - tgt: 'pgsql.localmonkey'

update:
  cmd.state.highstate:
    - tgt: 'jumphost.localmonkey'
