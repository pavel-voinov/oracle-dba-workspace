/*
*/
set serveroutput on size unlimited echo off

ACCEPT owner PROMPT "Owner: "
ACCEPT table_name DEFAULT '.*' PROMPT "Table name (All if not specified): "

column owner format a30
column table_name format a30
column constraint_name format a30

PROMPT Disabled foreign keys (before)
SELECT owner, table_name, constraint_name
FROM dba_constraints
WHERE regexp_like(owner, '^&owner.$', 'i')
  AND regexp_like(table_name, '^&table_name.$', 'i')
  AND constraint_type = 'R'
  AND status = 'DISABLED'
/
PROMPT
PROMPT Enabling FKs...
begin
  dbms_output.enable(null);
  for x in (SELECT fk.owner || '."' || fk.table_name || '"' as table_name, fk.constraint_name
            FROM dba_constraints pk, dba_constraints fk
            WHERE regexp_like(pk.table_name, '^&table_name.$', 'i') AND
              pk.owner = '&owner' AND
              fk.owner = pk.owner AND
              fk.r_constraint_name = pk.constraint_name AND
              fk.status = 'DISABLED') loop
    begin
      execute immediate 'ALTER TABLE ' || x.table_name || ' ENABLE CONSTRAINT "' || x.constraint_name || '"';
    exception
      when others then
        dbms_output.put_line(SQLERRM);
    end;
  end loop;
end;
/
PROMPT
PROMPT Still disabled foreign keys (after)
SELECT owner, table_name, constraint_name
FROM dba_constraints
WHERE regexp_like(owner, '^&owner.$', 'i')
  AND regexp_like(table_name, '^&table_name.$', 'i')
  AND constraint_type = 'R'
  AND status = 'DISABLED'
/

undefine owner
undefine table_name
