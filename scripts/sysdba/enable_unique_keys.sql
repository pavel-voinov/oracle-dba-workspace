/*
*/
set serveroutput on size unlimited echo off

define p_owner=&1
define p_table_name=&2

PROMPT
PROMPT Disabled unique keys (before)
SELECT c.owner, c.table_name, c.constraint_name
FROM dba_constraints c
WHERE c.owner like upper('&p_owner')
  AND c.table_name like upper('&p_table_name')
  AND c.constraint_type = 'U'
  AND c.status = 'DISABLED'
  AND c.table_name not in (SELECT q.queue_table FROM dba_queues q WHERE q.owner = c.owner)
ORDER BY c.owner, c.table_name, c.constraint_name
/
PROMPT
PROMPT Enabling UKs...
begin
  dbms_output.enable(null);
  for x in (SELECT '"' || c.owner || '"."' || c.table_name || '"' as table_name, '"' || c.constraint_name || '"' as constraint_name
            FROM dba_constraints c, dba_tables t
            WHERE c.owner like upper('&p_owner')
              AND c.table_name like upper('&p_table_name')
              AND t.iot_type is null
              AND c.owner = t.owner
              AND c.table_name = t.table_name
              AND t.table_name not in (SELECT queue_table FROM dba_queues WHERE owner = t.owner)
              AND c.constraint_type = 'U'
              AND c.status = 'DISABLED') loop
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
SELECT c.owner, c.table_name, c.constraint_name
FROM dba_constraints c
WHERE c.owner like upper('&p_owner')
  AND c.table_name like upper('&p_table_name')
  AND c.constraint_type = 'U'
  AND c.status = 'DISABLED'
  AND c.table_name not in (SELECT q.queue_table FROM dba_queues q WHERE q.owner = c.owner)
ORDER BY c.owner, c.table_name, c.constraint_name
/
