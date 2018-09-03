/*
*/
set serveroutput on size unlimited echo off

define owner=&1
define table_name='&2'

column owner format a30
column table_name format a30
column constraint_name format a30

PROMPT Already disabled foreign keys (before)
SELECT fk.owner, fk.table_name, fk.constraint_name
FROM dba_constraints pk, dba_constraints fk
WHERE regexp_like(pk.table_name, '^&table_name.$', 'i') AND
   pk.owner = '&owner' AND
   fk.owner = pk.owner AND
   fk.r_constraint_name = pk.constraint_name AND
   fk.status = 'DISABLED'
ORDER BY fk.owner, fk.table_name, fk.constraint_name
/
PROMPT
PROMPT Disabling FKs...
begin
  dbms_output.enable(null);
  for x in (SELECT fk.owner || '."' || fk.table_name || '"' as table_name, fk.constraint_name
            FROM dba_constraints pk, dba_constraints fk
            WHERE regexp_like(pk.table_name, '^&table_name.$', 'i') AND
              pk.owner = '&owner' AND
              fk.owner = pk.owner AND
              fk.r_constraint_name = pk.constraint_name AND
              fk.status = 'ENABLED') loop
    begin
      execute immediate 'ALTER TABLE ' || x.table_name || ' DISABLE CONSTRAINT "' || x.constraint_name || '"';
    exception
      when others then
        dbms_output.put_line(SQLERRM);
    end;
  end loop;
end;
/
PROMPT
PROMPT Still enabled foreign keys (after)
SELECT fk.owner, fk.table_name, fk.constraint_name
FROM dba_constraints pk, dba_constraints fk
WHERE regexp_like(pk.table_name, '^&table_name.$', 'i') AND
   pk.owner = '&owner' AND
   fk.owner = pk.owner AND
   fk.r_constraint_name = pk.constraint_name AND
   fk.status = 'ENABLED'
ORDER BY fk.owner, fk.table_name, fk.constraint_name
/

undefine owner
undefine table_name
