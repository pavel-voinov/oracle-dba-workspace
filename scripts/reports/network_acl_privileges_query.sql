/*
*/
column acl format a30 heading "ACL"
column principal format a30 heading "Principal"
column privilege format a30 heading "Privilege"
column is_grant format a10 heading "Granted"
column invert format a10 heading "Inverted"

SELECT regexp_replace(acl, '^\/sys\/acls\/') as acl, principal, privilege, is_grant, invert
FROM dba_network_acl_privileges
ORDER BY 1, 2, 3
/
