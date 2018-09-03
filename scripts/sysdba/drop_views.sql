/*
*/
set serveroutput on size unlimited echo off scan on verify off

define schema=&1

PROMPT Drop all views in schema &schema:

PROMPT Views count - before:
SELECT count(*) as cnt FROM dba_views WHERE owner = upper('&schema')
/
declare
  l_SQL varchar2(32000);
begin
  dbms_output.enable(null);
  for t in (select owner, view_name
            from dba_views
            where owner = upper('&schema'))
  loop
    l_SQL := 'DROP VIEW "' || t.owner || '"."' || t.view_name || '"';
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
PROMPT Views remained in schema:
SELECT owner, view_name FROM dba_views WHERE owner = upper('&schema')
ORDER BY 1, 2
/
