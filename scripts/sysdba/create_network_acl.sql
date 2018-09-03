define acl_name=ls_api_for_genego
define acl_descr='SOAP calls for LS API from GeneGo databases'
define acl_host=localhost
define acl_port=8080

declare
  l_first_time boolean := true;
  l_exists     boolean := false;
  l_cnt integer;
  l_acl varchar2(255);
begin
  l_acl := regexp_replace('&acl_name', '\.(xml|XML)$');
  SELECT count(*) INTO l_cnt
  FROM dba_network_acls
  WHERE regexp_like(acl, '^\/sys\/acls\/' || l_acl || '(|.xml)$', 'i');
  l_exists := l_cnt > 0;

  for u in (SELECT username, decode(rn, 1, 'connect', 2, 'resolve') as privilege
            FROM dba_users, (select rownum as rn from dual connect by level < 3)
            WHERE regexp_like(username, '^(DEVEL|GG_EXTDATA)$', 'i')
            ORDER BY 1, 2)
  loop
    if l_first_time then
      if not l_exists then
        dbms_network_acl_admin.create_acl(acl => '&acl_name..xml', description => '&acl_descr', principal => u.username, is_grant => true, privilege => u.privilege);
        dbms_network_acl_admin.assign_acl(acl => '&acl_name..xml', host => '&acl_host', lower_port => '&acl_port', upper_port => '&acl_port');
        commit;
      end if;
    else
      dbms_network_acl_admin.add_privilege(acl => '&acl_name..xml', principal => u.username, is_grant => true, privilege => u.privilege);
    end if;
    l_first_time := false;
  end loop;
  commit;
end;
/
