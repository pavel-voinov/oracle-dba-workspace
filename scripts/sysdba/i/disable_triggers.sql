/*
*/
set serveroutput on size unlimited echo off

ACCEPT owner PROMPT "Owner: "
ACCEPT table_name DEFAULT '.*' PROMPT "Table name (All if not specified): "

PROMPT
PROMPT Disabled triggers (before)
SELECT t.owner, t.table_name, t.trigger_name
FROM dba_triggers t
WHERE regexp_like(t.owner, '^&owner.$', 'i')
  AND regexp_like(t.table_name, '^&table_name.$', 'i')
  AND t.status = 'DISABLED'
  AND t.table_name not in (SELECT q.queue_table FROM dba_queues q WHERE q.owner = t.owner)
/
PROMPT
PROMPT Disabling triggers...
begin
  dbms_output.enable(null);
  for x in (SELECT '"' || t.owner || '"."' || t.trigger_name || '"' as trigger_name
            FROM dba_triggers t
            WHERE regexp_like(t.owner, '^&owner.$', 'i')
              AND regexp_like(t.table_name, '^&table_name.$', 'i')
              AND t.table_name not in (SELECT queue_table FROM dba_queues WHERE owner = t.owner)
              AND t.status = 'ENABLED') loop
    begin
      execute immediate 'ALTER TRIGGER ' || x.trigger_name || ' DISABLE';
    exception
      when others then
        dbms_output.put_line(SQLERRM);
    end;
  end loop;
end;
/
PROMPT
PROMPT Disabled triggers (after)
SELECT t.owner, t.table_name, t.trigger_name
FROM dba_triggers t
WHERE regexp_like(t.owner, '^&owner.$', 'i')
  AND regexp_like(t.table_name, '^&table_name.$', 'i')
  AND t.status = 'DISABLED'
  AND t.table_name not in (SELECT q.queue_table FROM dba_queues q WHERE q.owner = t.owner)
/
undefine owner
undefine table_name
