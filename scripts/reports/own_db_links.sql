/*
*/
@@reports.inc

column owner format a20 heading "Owner"
column db_link format a40 heading "Link name"
column username format a30 heading "Username"
column host format a80 heading "Connection string"

SELECT owner, db_link, username, host
FROM dba_db_links
WHERE owner in (user, 'PUBLIC')
ORDER BY 1, 2
/
