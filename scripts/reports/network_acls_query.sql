/*
*/
column acl format a30 heading "ACL"
column host format a30 heading "Host"
column ports format a20 heading "Ports|Lower/Upper"
column description format a50 heading "Description" word_wrapped

SELECT regexp_replace(a.acl, '^\/sys\/acls\/') as acl, a.host, decode(a.lower_port, null, '', a.lower_port || '/' || a.upper_port) as ports, x.description
FROM dba_network_acls a, xds_acl x
WHERE x.aclid(+) = a.aclid
ORDER BY 1, 2
/
