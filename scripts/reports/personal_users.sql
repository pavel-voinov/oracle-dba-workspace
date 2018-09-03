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
WHERE regexp_like(username, '^U[CX0-9]{7}$')
ORDER BY 1
/

column proxy format a8 heading "Username"
column schemas format a171 heading "Client schema(s)" word_wrap

SELECT proxy, listagg(client, ',') within group (order by client) as schemas
FROM dba_proxies
WHERE regexp_like(proxy, '^U[CX0-9]{7}$')
GROUP BY proxy
ORDER BY 1, 2
/
