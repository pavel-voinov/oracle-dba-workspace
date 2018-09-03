/*
*/
set serveroutput on size unlimited echo off feedback off timing off

ACCEPT table_name DEFAULT '.*' PROMPT "Table name (All if not specified): "

column owner format a30
column table_name format a30

PROMPT Tables with already disabled monitoring (before)
SELECT t.owner, t.table_name
FROM all_tables t
WHERE t.owner = sys_context('USERENV', 'CURRENT_SCHEMA')
  AND regexp_like(t.table_name, '^&table_name.$', 'i')
  AND t.monitoring = 'NO'
  AND not exists (SELECT null FROM all_queues q WHERE q.owner = t.owner AND q.queue_table = t.table_name)
/
PROMPT
PROMPT Disabling monitoring...
begin
  dbms_output.enable(null);
  for x in (SELECT '"' || t.owner || '"."' || t.table_name || '"' as table_name
            FROM all_tables t
            WHERE t.owner = sys_context('USERENV', 'CURRENT_SCHEMA')
              AND regexp_like(t.table_name, '^&table_name.$', 'i')
              AND not exists (SELECT null FROM all_queues q WHERE q.owner = t.owner AND q.queue_table = t.table_name)
              AND t.monitoring = 'YES')
  loop
    begin
      execute immediate 'ALTER TABLE ' || x.table_name || ' NOMONITORING';
    exception
      when others then
        dbms_output.put_line(SQLERRM);
    end;
  end loop;
  commit;
end;
/
PROMPT
PROMPT Tables with still enabled monitoring (after)
SELECT t.owner, t.table_name
FROM all_tables t
WHERE t.owner = sys_context('USERENV', 'CURRENT_SCHEMA')
  AND regexp_like(t.table_name, '^&table_name.$', 'i')
  AND t.monitoring = 'YES'
  AND not exists (SELECT null FROM all_queues q WHERE q.owner = t.owner AND q.queue_table = t.table_name)
/
set feedback on
