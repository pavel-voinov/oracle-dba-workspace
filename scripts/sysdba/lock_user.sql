/*
*/
set serveroutput on size unlimited buffer 100000 verify off timing off scan on

define p_user=&1

PROMPT Lock "&p_user" user

begin
  dbms_output.enable(null);
  for u in (SELECT username FROM dba_users
            WHERE username = upper('&p_user')
              AND account_status = 'OPEN')
  loop
    begin
      execute immediate 'ALTER USER "' || u.username  || '" ACCOUNT LOCK';
      dbms_output.put_line(u.username || ': locked');
    exception when others then
      dbms_output.put_line(u.username || ': ' || SQLERRM);
    end;
  end loop;
end;
/

undefine p_users
