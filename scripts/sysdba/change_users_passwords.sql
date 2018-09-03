/*
Script to change passwords to lower case of username for all non-system and not-special users
*/
set serveroutput on size unlimited buffer 100000 verify off timing off scan on

@system_users_filter.sql

begin
  dbms_output.enable(null);
  for u in (SELECT username
            FROM dba_users
            WHERE not regexp_like(username, :v_sys_users_regexp)
              AND not regexp_like(username, '^(C\$MDL.*|GGS)$', 'i'))
  loop
    begin
      dbms_output.put_line('ALTER USER "' || u.username  || '" IDENTIFIED BY "' || lower(u.username) || '"');
      execute immediate 'ALTER USER "' || u.username  || '" IDENTIFIED BY "' || lower(u.username) || '"';
    exception when others then
      dbms_output.put_line(u.username || ': ' || SQLERRM);
    end;
  end loop;
end;
/
