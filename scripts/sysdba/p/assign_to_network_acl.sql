define acl_name=&1
define username=&2

declare
  l_cnt integer;
  l_acl varchar2(255);
begin
  l_acl := regexp_replace('&acl_name', '\.(xml|XML)$');
  SELECT count(*) INTO l_cnt
  FROM dba_network_acls
  WHERE regexp_like(acl, '^\/sys\/acls\/' || l_acl || '(|.xml)$', 'i');

  if l_cnt > 0 then
    for u in (SELECT username, decode(rn, 1, 'connect', 2, 'resolve') as privilege
              FROM dba_users, (select rownum as rn from dual connect by level < 3)
              WHERE regexp_like(username, '^&username.$', 'i')
              ORDER BY 1, 2)
    loop
      dbms_network_acl_admin.add_privilege(acl => '&acl_name..xml', principal => u.username, is_grant => true, privilege => u.privilege);
    end loop;
    commit;
  else
    dbms_output.put_line('Network ACL "&acl_name" does not exist');
  end if;
end;
/
