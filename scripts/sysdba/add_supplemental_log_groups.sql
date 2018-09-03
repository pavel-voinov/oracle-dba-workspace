/*
*/
set serveroutput on size unlimited echo off scan on verify off

define schema=&1

PROMPT Drop all supplemental log groups in schema &schema tables:

PROMPT Log groups count - before:
SELECT count(*) as cnt FROM dba_log_groups WHERE owner = upper('&schema')
/
declare
  l_SQL varchar2(32000);
begin
  dbms_output.enable(null);
  for t in (SELECT owner, table_name, log_group_name
            FROM dba_log_groups
            WHERE owner = upper('&schema'))
  loop
    l_SQL := 'ALTER TABLE "' || t.owner || '"."' || t.table_name || '" DROP SUPPLEMENTAL LOG GROUP "' || t.log_group_name || '"';
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
column owner format a30
column table_name format a30
column log_group_name format a30
PROMPT Log groups remained in schema:
SELECT owner, table_name, log_group_name FROM dba_log_groups WHERE owner = upper('&schema')
ORDER BY 1, 2
/
