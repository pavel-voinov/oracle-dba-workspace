/*
*/
set serveroutput on size unlimited echo off timing on

declare
  l_first integer := to_number('&1');
  l_last integer := to_number('&2');
begin
  dbms_output.enable(null);
  for l in (SELECT group# as group_id FROM v$log
            WHERE group# BETWEEN l_first AND l_last
              AND status in ('INACTIVE', 'UNUSED') AND archived = 'YES')
  loop
    begin
      execute immediate 'ALTER DATABASE DROP LOGFILE GROUP ' || l.group_id;
    exception when others then
      dbms_output.put_line(l.group_id || ': ' || SQLERRM);
    end;
  end loop;
exception when others then
  dbms_output.put_line(SQLERRM);
end;
/
