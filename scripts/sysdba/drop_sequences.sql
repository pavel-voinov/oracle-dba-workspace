/*
*/
set serveroutput on size unlimited echo off scan on verify off

define schema=&1

PROMPT Drop all sequences in schema &schema:

PROMPT Sequences count - before:
SELECT count(*) as cnt FROM dba_sequences WHERE sequence_owner = upper('&schema')
/
declare
  l_SQL varchar2(32000);
begin
  dbms_output.enable(null);
  for t in (select '"' || sequence_owner || '"."' || sequence_name || '"' as sequence_name
            from dba_sequences
            where sequence_owner = upper('&schema'))
  loop
    l_SQL := 'DROP SEQUENCE ' || t.sequence_name;
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
PROMPT Sequences remained in schema:
SELECT sequence_owner, sequence_name FROM dba_sequences WHERE sequence_owner = upper('&schema')
ORDER BY 1, 2
/
