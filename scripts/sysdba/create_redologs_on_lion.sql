/*
*/
set serveroutput on size unlimited echo off timing on

declare
  l_thread integer := to_number('&1');
  l_first integer := to_number('&2');
  l_last integer := to_number('&3');
  l_size varchar2(20) := '&4';
begin
  dbms_output.enable(null);
  for l in (SELECT rownum + l_first - 1 as group_id FROM dual CONNECT BY level <= (l_last - l_first + 1)
            MINUS
            SELECT group# FROM v$log)
  loop
    begin
      execute immediate 'ALTER DATABASE ADD LOGFILE THREAD ' || l_thread || ' GROUP ' || l.group_id || ' SIZE ' || l_size;
    exception when others then
      dbms_output.put_line(l_thread || ' - ' || l.group_id || ': ' || SQLERRM);
    end;
  end loop;
exception when others then
  dbms_output.put_line(SQLERRM);
end;
/
