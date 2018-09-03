/*
*/
set serveroutput on size unlimited echo off scan on verify off

define schema=&1

PROMPT Drop all mviews with preserve table option in schema &schema:

PROMPT Materialized views count - before:
SELECT count(*) as cnt FROM dba_mviews WHERE owner = upper('&schema')
/
declare
  l_SQL varchar2(32000);
begin
  dbms_output.enable(null);
  for t in (select owner, mview_name
            from dba_mviews
            where owner = upper('&schema'))
  loop
    l_SQL := 'DROP MATERIALIZED VIEW "' || t.owner || '"."' || t.mview_name || '" PRESERVE TABLE';
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
PROMPT Materialized views remained in schema:
SELECT owner, mview_name FROM dba_mviews WHERE owner = upper('&schema')
ORDER BY 1, 2
/
