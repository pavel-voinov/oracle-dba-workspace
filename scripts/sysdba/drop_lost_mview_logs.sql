/*
*/
set serveroutput on size unlimited echo off scan on verify off

define schema=&1

PROMPT Drop MLOG$_% tables which are not related to mview logs in schema &schema:

declare
  l_SQL varchar2(32000);
begin
  dbms_output.enable(null);
  for t in (SELECT owner, table_name FROM dba_tables WHERE owner = upper('&schema') AND table_name like 'MLOG$_%'
            MINUS
            SELECT log_owner, log_table FROM dba_mview_logs WHERE log_owner = upper('&schema')
            ORDER BY 1, 2)
  loop
    l_SQL := 'DROP TABLE "' || t.owner || '"."' || t.table_name || '"';
    begin
      dbms_output.put(l_SQL || ';');
      execute immediate l_SQL;
      dbms_output.put_line(' -- OK');
    exception when others then
      dbms_output.put_line(':' || SQLERRM);
    end;
  end loop;
end;
/
