/*
*/
set serveroutput on size unlimited echo off

ACCEPT owner PROMPT "Owner: "
ACCEPT table_name DEFAULT '.*' PROMPT "Table name (All if not specified): "

PROMPT
PROMPT Disabled unique keys (before)
SELECT c.owner, c.table_name, c.constraint_name
FROM dba_constraints c
WHERE regexp_like(c.owner, '^&owner.$', 'i')
  AND regexp_like(c.table_name, '^&table_name.$', 'i')
  AND c.constraint_type = 'U'
  AND c.status = 'DISABLED'
  AND c.table_name not in (SELECT q.queue_table FROM dba_queues q WHERE q.owner = c.owner)
/
PROMPT
PROMPT Disabling UKs...
begin
  dbms_output.enable(null);
  for x in (SELECT '"' || c.owner || '"."' || c.table_name || '"' as table_name, '"' || c.constraint_name || '"' as constraint_name
            FROM dba_constraints c, dba_tables t
            WHERE regexp_like(t.owner, '^&owner.$', 'i')
              AND regexp_like(t.table_name, '^&table_name.$', 'i')
              AND t.iot_type is null
              AND c.owner = t.owner
              AND c.table_name = t.table_name
              AND t.table_name not in (SELECT queue_table FROM dba_queues WHERE owner = t.owner)
              AND c.constraint_type = 'U'
              AND c.status = 'ENABLED') loop
    begin
      execute immediate 'ALTER TABLE ' || x.table_name || ' DISABLE CONSTRAINT ' || x.constraint_name || ' DROP INDEX';
    exception
      when others then
        dbms_output.put_line(SQLERRM);
    end;
  end loop;
end;
/
PROMPT
PROMPT Disabled unique keys (after)
SELECT c.owner, c.table_name, c.constraint_name
FROM dba_constraints c
WHERE regexp_like(c.owner, '^&owner.$', 'i')
  AND regexp_like(c.table_name, '^&table_name.$', 'i')
  AND c.constraint_type = 'U'
  AND c.status = 'DISABLED'
  AND c.table_name not in (SELECT q.queue_table FROM dba_queues q WHERE q.owner = c.owner)
/
undefine owner
undefine table_name
