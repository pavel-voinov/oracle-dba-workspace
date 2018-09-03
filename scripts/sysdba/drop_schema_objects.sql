/*
*/
set serveroutput on size unlimited echo off scan on verify off

define schema=&1

PROMPT Drop all database objects from schema &schema:

PROMPT Objects count before:
SELECT object_type, count(*) as cnt
FROM dba_objects
WHERE owner = upper('&schema')
GROUP BY object_type
/
-- Drop domain indexes first
declare
  l_SQL varchar2(32000);
begin
  dbms_output.enable(null);
  for t in (select owner, index_name
            from dba_indexes
            where owner = upper('&schema')
              AND index_type = 'DOMAIN')
  loop
    l_SQL := 'DROP INDEX "' || t.owner || '"."' || t.index_name || '" FORCE';
    begin
      dbms_output.put(l_SQL);
      execute immediate l_SQL;
      dbms_output.put_line(' -- OK');
    exception when others then
      dbms_output.put_line(':' || SQLERRM);
    end;
  end loop;
end;
/
-- Drop refresh groups
begin
  dbms_output.enable(null);
  for t in (select '"' || rowner || '"."' || rname || '"' as group_name
            from dba_refresh
            where rowner = upper('&schema'))
  loop
    begin
      dbms_output.put('Drop refresh group: ' || t.group_name);
      dbms_refresh.destroy(t.group_name);
      dbms_output.put_line(' -- OK');
    exception when others then
      dbms_output.put_line(': ' || SQLERRM);
    end;
  end loop;
end;
/
-- Drop objects
declare
  l_SQL varchar2(32000);
begin
  dbms_output.enable(null);
  for t in (select owner, object_name, object_type
            from dba_objects
            where owner = upper('&schema')
              and object_type in ('PROCEDURE', 'FUNCTION', 'TYPE', 'PACKAGE', 'TRIGGER', 'MATERIALIZED VIEW', 'VIEW', 'SYNONYM', 'SEQUENCE', 'TABLE', 'LIBRARY', 'OPERATOR', 'INDEXTYPE')
              and secondary = 'N'
            order by decode(object_type, 'PROCEDURE', 1, 'FUNCTION', 2, 'TYPE', 3, 'PACKAGE', 4, 'TRIGGER', 5,
              'MATERIALIZED VIEW', 6, 'VIEW', 7, 'SYNONYM', 8, 'SEQUENCE', 9, 10))
  loop
    l_SQL := 'DROP ' || t.object_type || ' "' || t.owner || '"."' || t.object_name || '"';
    if t.object_type = 'TABLE' then
      l_SQL := l_SQL || ' CASCADE CONSTRAINTS PURGE';
    elsif t.object_type IN ('TYPE', 'OPERATOR') then
      l_SQL := l_SQL || ' FORCE';
    end if;
    begin
      dbms_output.put(l_SQL);
      execute immediate l_SQL;
      dbms_output.put_line(' -- OK');
    exception when others then
      dbms_output.put_line(':' || SQLERRM);
    end;
  end loop;
end;
/
-- Drop jobs
declare
  l_SQL varchar2(32000);
begin
  dbms_output.enable(null);
  for t in (select owner, job_name
            from dba_scheduler_jobs
            where owner = upper('&schema'))
  loop
    l_SQL := 'exec dbms_scheduler.drop_job(job_name => ''"' || t.owner || '"."' || t.job_name || '"'', force => true);';
    begin
      dbms_output.put(l_SQL);
      dbms_scheduler.drop_job(job_name => '"' || t.owner || '"."' || t.job_name || '"', force => true);
      dbms_output.put_line(' -- OK');
    exception when others then
      dbms_output.put_line(':' || SQLERRM);
    end;
  end loop;
end;
/
PROMPT Remained objects:
SELECT owner, object_type, object_name FROM dba_objects WHERE owner = upper('&schema')
ORDER BY 1, 2, 3
/
