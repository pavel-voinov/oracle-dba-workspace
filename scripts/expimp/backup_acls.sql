/*

This script backups network ACLs
*/

set serveroutput on size 1000000 linesize 1024 pagesize 9999 trimspool on newpage none heading off feedback off timing off

column sql_text format a4000 word_wrapped

SELECT 'begin dbms_network_acl_admin.create_acl(acl => ''' || acl || ''', description => ''' || description || ''',
 principal => ''' || principal || ''', is_grant => ' || is_grant || ', privilege => ''' || privilege || '''); end;' || chr(10) || '/' as sql_text
FROM (SELECT a.*, p.principal, p.privilege, p.is_grant, x.description,
        row_number() over (partition by p.acl order by p.principal, p.privilege) as rn
      FROM dba_network_acls a, dba_network_acl_privileges p, xds_acl x
      WHERE p.aclid = a.aclid AND x.aclid(+) = a.aclid)
WHERE rn = 1;

SELECT 'begin dbms_network_acl_admin.assign_acl(acl => ''' || acl || ''', host => ''' || host || ''', lower_port => ' || nvl(to_char(lower_port), 'null') ||
  ', upper_port => ' || nvl(to_char(upper_port), 'null') || '); end;' || chr(10) || '/' as sql_text
FROM dba_network_acls;

SELECT 'begin dbms_network_acl_admin.add_privilege(acl => ''' || acl || ''', principal => ''' || principal || ''', is_grant => ' || is_grant
  || ', privilege => ''' || privilege || '''); end;' || chr(10) || '/' as sql_text
FROM (SELECT a.*, p.principal, p.privilege, p.is_grant,
        row_number() over (partition by p.acl order by p.principal, p.privilege) as rn
      FROM dba_network_acls a, dba_network_acl_privileges p
      WHERE p.aclid = a.aclid)
WHERE rn > 1;
