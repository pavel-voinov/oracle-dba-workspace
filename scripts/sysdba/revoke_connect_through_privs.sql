/*
Script to revoke privileges for proxy connection for all non-system and non-special users
*/
set serveroutput on size unlimited buffer 100000 verify off timing off scan on
@system_users_filter.sql

define proxy_user=&1

column proxy_user new_value proxy_user
SELECT username as proxy_user
FROM dba_users
WHERE regexp_like(username, '^&proxy_user.$', 'i');
/
begin
  dbms_output.enable(null);
  for u in (SELECT username
            FROM dba_users
            WHERE not regexp_like(username, :v_sys_users_regexp)
              AND not regexp_like(username, '^(C\$MDL.*|&proxy_user)$', 'i'))
  loop
    begin
      dbms_output.put_line('ALTER USER "' || u.username  || '" REVOKE CONNECT THROUGH "&proxy_user"' || ';');
      execute immediate 'ALTER USER "' || u.username  || '" REVOKE CONNECT THROUGH "&proxy_user"';
    exception when others then
      dbms_output.put_line(u.username || ': ' || SQLERRM);
    end;
  end loop;
end;
/
undefine proxy_user
