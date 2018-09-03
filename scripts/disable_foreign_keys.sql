/*
*/
set serveroutput on size unlimited echo off feedback off timing off

ACCEPT table_name DEFAULT '.*' PROMPT "Table name (All if not specified): "

column owner format a30
column table_name format a30
column constraint_name format a30

PROMPT Disabled foreign keys (before)
SELECT owner, table_name, constraint_name
FROM all_constraints
WHERE owner = sys_context('USERENV', 'CURRENT_SCHEMA')
  AND regexp_like(table_name, '^&table_name.$', 'i')
  AND constraint_type = 'R'
  AND status = 'DISABLED'
/
PROMPT
PROMPT Disabling FKs...
begin
  dbms_output.enable(null);
  for x in (SELECT '"' || owner || '"."' || table_name || '"' as table_name, '"' || constraint_name || '"' as constraint_name
            FROM all_constraints
            WHERE owner = sys_context('USERENV', 'CURRENT_SCHEMA')
              AND regexp_like(table_name, '^&table_name.$', 'i')
              AND constraint_type = 'R'
              AND status = 'ENABLED')
  loop
    begin
      execute immediate 'ALTER TABLE ' || x.table_name || ' DISABLE CONSTRAINT ' || x.constraint_name;
    exception
      when others then
        dbms_output.put_line(SQLERRM);
    end;
  end loop;
end;
/
PROMPT
PROMPT Disabled foreign keys (before)
SELECT owner, table_name, constraint_name
FROM all_constraints
WHERE owner = sys_context('USERENV', 'CURRENT_SCHEMA')
  AND regexp_like(table_name, '^&table_name.$', 'i')
  AND constraint_type = 'R'
  AND status = 'DISABLED'
/
set feedback on
