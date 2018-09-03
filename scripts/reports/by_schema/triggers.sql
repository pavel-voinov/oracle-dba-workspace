/*
*/
@reports/reports_header

define schema=&1

column trigger_name format a30 heading "Trigger name"
column trigger_type format a16 heading "Trigger type"
column triggering_event format a26 heading "Event"
column table_name format a30 heading "Base object|name"
column base_object_type format a11 heading "Base object|type"
column action_type format a20 heading "Action type"
column status format a8 heading "Status"
column after_before format a14 heading "After/before|Statement:Row"
column when_clause format a38 heading "When clause" word_wrapped

SELECT trigger_name, trigger_type, status, triggering_event,
  base_object_type, decode(table_owner, owner, '', table_owner || '.') || table_name as table_name,
  when_clause
--  after_statement || '/' || before_statement || ':' || after_row || '/' || before_row as after_before
FROM dba_triggers
WHERE owner = '&schema'
ORDER BY 1
/
