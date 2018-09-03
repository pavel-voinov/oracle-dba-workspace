/*
*/
set serveroutput on size unlimited echo off scan on verify off

define schema=&1

PROMPT Drop all types in schema &schema:

PROMPT Types count - before:
SELECT count(*) as cnt FROM dba_types WHERE owner = upper('&schema')
/
declare
  l_SQL varchar2(32000);
begin
  dbms_output.enable(null);
  for t in (select owner, type_name
            from dba_types
            where owner = upper('&schema'))
  loop
    l_SQL := 'DROP TYPE "' || t.owner || '"."' || t.trigger_name || '" FORCE';
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
PROMPT Types remained in schema:
SELECT owner, type_name FROM dba_types WHERE owner = upper('&schema')
ORDER BY 1, 2
/
