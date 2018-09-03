/*
*/
set serveroutput on size unlimited echo off feedback off timing off

PROMPT Count of disabled foreign keys (before)
SELECT count(*) as cnt
FROM all_constraints
WHERE owner = sys_context('USERENV', 'CURRENT_SCHEMA')
  AND constraint_type = 'R'
  AND status = 'DISABLED'
/
PROMPT Enabling FKs...
begin
  dbms_output.enable(null);
  for x in (SELECT '"' || owner || '"."' || table_name || '"' as table_name, '"' || constraint_name || '"' as constraint_name
            FROM all_constraints
            WHERE owner = sys_context('USERENV', 'CURRENT_SCHEMA')
              AND constraint_type = 'R'
              AND status = 'DISABLED')
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
PROMPT Count of disabled foreign keys (after)
SELECT count(*) as cnt
FROM all_constraints
WHERE owner = sys_context('USERENV', 'CURRENT_SCHEMA')
  AND constraint_type = 'R'
  AND status = 'DISABLED'
/
set feedback on
