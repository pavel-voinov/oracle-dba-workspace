/*
*/
@@reports.inc

column username format a30 heading "User name"
column account_status format a20 heading "Status"
column default_tablespace format a30 heading "Default tablespace"
column temporary_tablespace format a30 heading "Temporary tablespace"
column profile format a30 heading "Profile name"

SELECT username, account_status, default_tablespace, temporary_tablespace, profile
FROM dba_users
WHERE not regexp_like(username, '^U[CX0-9]{7}$')
ORDER BY 1
/

