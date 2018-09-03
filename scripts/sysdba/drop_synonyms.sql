/*
*/
set serveroutput on size unlimited echo off scan on verify off

define schema=&1

PROMPT Drop all synonyms in schema &schema:

PROMPT Synonyms count - before:
SELECT count(*) as cnt FROM dba_synonyms WHERE owner = upper('&schema')
/
declare
  l_SQL varchar2(32000);
begin
  dbms_output.enable(null);
  for t in (select owner, synonym_name
            from dba_synonyms
            where owner = upper('&schema'))
  loop
    l_SQL := 'DROP SYNONYM "' || t.owner || '"."' || t.synonym_name || '"';
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
PROMPT Synonyms remained in schema:
SELECT owner, synonym_name FROM dba_synonyms WHERE owner = upper('&schema')
ORDER BY 1, 2
/
