base:
  '*':
    - packages
    - salt.minion
    - salt.minion.monit
    - users
    - auditd
    - reboot
  '*.localmonkey':
    - mail
  'jumphost.localmonkey':
    - ssh.server
  'pgsql.localmonkey':
    - ferm
    - postgresql.server
    - postgresql.server.tablespaces
    - postgresql.server.roles
    - postgresql.server.databases
  'mysql.localmonkey':
    - mysql.server
    - mysql.roles
    - mysql.databases
    - phpmyadmin
    - ferm
  'master.localmonkey':
    - users.accounts.git
    - mysql.client
    - ferm
    - gitorious
