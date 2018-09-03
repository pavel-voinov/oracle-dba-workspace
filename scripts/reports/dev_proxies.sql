/*
*/
@@reports.inc

column proxy format a30 heading "Proxy username"
column client format a30 heading "Client username"
column role format a10 heading "Role"
column proxy_authority format a20 heading "Proxy authority"
column authentication format a15 heading "Authentication"
column authorization_constraint format a35 heading "Authentication constraint"

SELECT proxy, client, proxy_authority, authentication, authorization_constraint, role
FROM dba_proxies
WHERE regexp_like(proxy, '^U[CX0-9]{7}$')
  OR regexp_like(client, '^U[CX0-9]{7}$')
ORDER BY 1, 2
/
