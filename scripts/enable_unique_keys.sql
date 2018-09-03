/*
*/
set serveroutput on size unlimited echo off feedback off timing off

ACCEPT table_name DEFAULT '.*' PROMPT "Table name (All if not specified): "

column owner format a30
column table_name format a30
column constraint_name format a30

PROMPT Disabled unique keys (before)
SELECT owner, table_name, constraint_name
FROM all_constraints
WHERE owner = sys_context('USERENV', 'CURRENT_SCHEMA')
  AND regexp_like(table_name, '^&table_name.$', 'i')
  AND constraint_type = 'U'
  AND status = 'DISABLED'
  AND table_name not in (SELECT queue_table FROM all_queues WHERE owner = sys_context('USERENV', 'CURRENT_SCHEMA'))
/
PROMPT
PROMPT Enabling UKs...
begin
  dbms_output.enable(null);
  for x in (SELECT '"' || c.owner || '"."' || c.table_name || '"' as table_name, '"' || c.constraint_name || '"' as constraint_name
            FROM all_constraints c, all_tables t
            WHERE t.owner = sys_context('USERENV', 'CURRENT_SCHEMA')
              AND regexp_like(t.table_name, '^&table_name.$', 'i')
              AND t.iot_type is null
              AND t.table_name not in (SELECT queue_table FROM all_queues WHERE owner = sys_context('USERENV', 'CURRENT_SCHEMA'))
              AND c.owner = t.owner
              AND c.table_name = t.table_name
              AND c.constraint_type = 'U'
              AND c.status = 'DISABLED')
  loop
    begin
      execute immediate 'ALTER TABLE ' || x.table_name || ' ENABLE CONSTRAINT ' || x.constraint_name;
    exception
      when others then
        dbms_output.put_line(SQLERRM);
    end;
  end loop;
end;
/
PROMPT
PROMPT Still disabled unique keys (after)
SELECT owner, table_name, constraint_name
FROM all_constraints
WHERE owner = sys_context('USERENV', 'CURRENT_SCHEMA')
  AND regexp_like(table_name, '^&table_name.$', 'i')
  AND constraint_type = 'U'
  AND status = 'DISABLED'
  AND table_name not in (SELECT queue_table FROM all_queues WHERE owner = sys_context('USERENV', 'CURRENT_SCHEMA'))
/
set feedback on
