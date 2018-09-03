/*
*/
set serveroutput on size unlimited buffer 100000 verify off timing off scan on

define p_users=&1

PROMPT Unlock "&p_users" users

begin
  dbms_output.enable(null);
  for u in (SELECT username FROM dba_users
            WHERE regexp_like(username, '^(' || replace('&p_users', ',', '|') || ')$', 'i')
              AND account_status = 'LOCKED')
  loop
    begin
      execute immediate 'ALTER USER "' || u.username  || '" ACCOUNT UNLOCK';
      dbms_output.put_line(u.username || ': unlocked');
    exception when others then
      dbms_output.put_line(u.username || ': ' || SQLERRM);
    end;
  end loop;
end;
/

undefine p_users
