/*
*/
set serveroutput on size unlimited echo off timing on

declare
  l_size_mb integer := to_number('&1');
begin
  dbms_output.enable(null);
  for l in (SELECT group# as group_id FROM v$log
            WHERE round(bytes / power(2, 20)) = l_size_mb
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
