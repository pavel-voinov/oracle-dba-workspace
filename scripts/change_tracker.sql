@@reports/reports.inc
set feedback off heading off

define action=&1

spool change_tracking.log append

column db_name format a15 heading "DB name"
column os_user format a25 heading "OS user"
column user format a25 heading "DB user"
column ts format a25 heading "Timestamp"
column action format a80 heading "Action"

SELECT to_char(systimestamp, 'DD.MM.YYYY HH24:MI') as ts, sys_context('USERENV', 'DB_NAME') as db_name, sys_context('USERENV', 'OS_USER') as os_user, user, '&action' as action
FROM dual;

spool off

set feedback on heading on
