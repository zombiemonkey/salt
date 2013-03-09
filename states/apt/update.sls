apt-get -qq update:
  cmd.run

apt-get -y -qq upgrade:
  cmd.run:
    - require:
      - cmd.run: apt-get -qq update

state.highstate:
  module.run:
    - test: False
    - require:
      - cmd.run: apt-get -y -qq upgrade  
