/*
*/
set serveroutput on size unlimited echo off

PROMPT Count of enabled foreign keys

begin
  dbms_output.enable(null);
  for x in (SELECT fk.owner || '."' || fk.table_name || '"' as table_name, fk.constraint_name
            FROM all_constraints pk, all_constraints fk
            WHERE pk.table_name = upper('&table_name') AND
              pk.owner = sys_context('USERENV', 'CURRENT_SCHEMA') AND
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
