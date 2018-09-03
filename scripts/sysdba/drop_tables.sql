/*
*/
set serveroutput on size unlimited echo off scan on verify off

define p_schema=&1
define p_tables=&2

PROMPT Drop "&p_tables" tables in schema "&p_schema":

PROMPT Tables count - before:
SELECT count(*) as cnt FROM dba_tables WHERE owner = upper('&p_schema') AND table_name like upper('&p_tables')
/
declare
  l_SQL varchar2(32000);
begin
  dbms_output.enable(null);
  for t in (SELECT '"' || owner || '"."' || table_name || '"' as table_name
            FROM dba_tables
            WHERE owner = upper('&p_schema')
              AND table_name like upper('&p_tables'))
  loop
    l_SQL := 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
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
PROMPT Tables remained in schema:
SELECT owner, table_name FROM dba_tables WHERE owner = upper('&p_schema') AND table_name like upper('&p_tables')
ORDER BY 1, 2
/
