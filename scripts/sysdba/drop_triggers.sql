/*
*/
set serveroutput on size unlimited echo off scan on verify off

define schema=&1

PROMPT Drop all triggers in schema &schema:

PROMPT Triggers count - before:
SELECT count(*) as cnt FROM dba_triggers WHERE owner = upper('&schema')
/
declare
  l_SQL varchar2(32000);
begin
  dbms_output.enable(null);
  for t in (select owner, trigger_name
            from dba_triggers
            where owner = upper('&schema'))
  loop
    l_SQL := 'DROP TRIGGER "' || t.owner || '"."' || t.trigger_name || '"';
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
PROMPT Triggers remained in schema:
SELECT owner, trigger_name FROM dba_triggers WHERE owner = upper('&schema')
ORDER BY 1, 2
/
