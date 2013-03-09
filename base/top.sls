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
  'pgsql.localmonkey':
    - ferm
    - postgresql.server.9_2
    - postgresql.server.9_2.tablespaces
    - postgresql.server.9_2.users
  'mysql.localmonkey':
    - mysql
    - ferm
  'master.localmonkey':
    - users.accounts.git
    - mysql.client
    - ferm
    - gitorious
