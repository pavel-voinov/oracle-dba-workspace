/*
*/
@@reports.inc

column username format a20 heading "Oracle user"
column os_client format a40 heading "OS client"
column timestamp format a30 heading "Timestamp"
column returncode format 9999990 heading "ReturnCode"
column proxy_username format a30 heading "Proxy Oracle user"
column proxy_os_client format a40 heading "Proxy OS client"

SELECT to_char(l.timestamp, 'DD.MM.YYYY HH24:MI:SS') as timestamp, l.username, l.os_username || '@' || l.userhost as os_client, l.returncode,
  p.username as proxy_username, decode(p.sessionid, null, '', p.os_username || '@' || p.userhost) as proxy_os_client
FROM dba_audit_trail l, dba_audit_trail p
WHERE l.username like upper('&1')
  AND l.action_name = 'LOGON'
  AND l.proxy_sessionid = p.sessionid(+)
ORDER BY l.timestamp
/
